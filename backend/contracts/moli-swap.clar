
;; moli-swap
;; <add a description here>


;;
;; 1. getReserve() - return amount of moli tokens held by th contract
;;  - get the balance of moli tokens in the contract
;; 2. addLiquidity(_amount) - add liquidity to the pool of STX/moli
;;  - define a variable liquidity
;;  - get the STX balance and save inside stxBalance variable
;;  - get the STX in the contract
;; 3. removeLiquidity() - returns the amount of STX/moli to be returned to the user
;; 4. getAmountOfToken() - return the amount of STX/moli tha would be returned to a user in a swap
;;  -   the amount of STX/moli to be returned to the user in a swap
;; 5. stxToMoliToken() - swap STX for moli tokens
;; 6. moliToStx() - swap moli tokens to stx
;;

(define-constant err-zero-stx (err u200))
(define-constant err-zero-tokens (err u201))
(define-constant fee-basis-points u50) ;; 0.5%

;; Get contract STX balance
(define-private (get-stx-balance)
  (stx-get-balance (as-contract tx-sender))
)

;; Get contract moli token balance
(define-private (get-moli-balance)
  (contract-call? .moli-token get-balance (as-contract tx-sender))
)

;; Get contract lima token balance
(define-private (get-lima-balance)
  (contract-call? .lima-token get-balance (as-contract tx-sender))
)

;; Provide initial liquidity, defining the initial exchange ratio 
(define-private (first-provide-liquidity (stx-amount uint) (token-amount uint) (provider principal) )
  
       (begin
      ;; send STX from tx-sender to the contract
      (try! (stx-transfer? stx-amount tx-sender (as-contract tx-sender)))
      ;; send tokens from tx-sender to the contract
      (try! (contract-call? .moli-token transfer token-amount tx-sender (as-contract tx-sender)))
      ;; mint LP tokens to tx-sender
      ;; inside as-contract the tx-sender is the exchange contract, so we use tx-sender passed into the function
      (as-contract (contract-call? .moli-lp mint stx-amount provider))
    )
)

;; Provide additional liquidity, matching the current ratio
;; the max token amount would be handled by post-conditions
(define-private ( add-liquidity (stx-amount uint))
  (let (
      ;; new tokens = additional STX * existing token balance / existing STX balance
      (contract-address (as-contract tx-sender))

      (stx-balance (get-stx-balance))
      (moli-balance (get-moli-balance))
      (tokens-to-transfer (/ (* stx-amount moli-balance) stx-balance))
      
      ;; new LP tokens = additional STX / existing STX balance * total existing LP tokens
      (liquidity-token-supply (contract-call? .moli-lp get-total-supply))
      ;; I've reversed the direction a bit here: we need to be careful not to do a division that floors to zero
      ;; additional STX / existing STX balance is likely to!
      ;; Then we end up with zero LP tokens and a sad tx-sender
      (liquidity-to-mint (/ (* stx-amount liquidity-token-supply) stx-balance))

      (provider tx-sender)
    ;;   (moli-balance (get-moli-balance))
    ;;   (tokens-to-transfer (/ (* stx-amount moli-balance) (get-stx-balance)))
    )
    (begin 
      ;; transfer STX from liquidity provider to contract
      (try! (stx-transfer? stx-amount tx-sender contract-address))
        ;; transfer tokens from liquidity provider to contract
      (try! (contract-call? .moli-token transfer tokens-to-transfer tx-sender contract-address))
      ;; mint LP tokens to tx-sender
      ;; inside as-contract the tx-sender is the exchange contract, so we use tx-sender passed into the function
      (as-contract (contract-call? .moli-lp mint liquidity-to-mint provider))
    )
  )
)

;; Anyone can provide liquidity by transferring STX and tokens to the contract
(define-public (provide-liquidity (stx-amount uint) (max-token-amount uint))
  (begin
    (asserts! (> stx-amount u0) err-zero-stx)
    (asserts! (> max-token-amount u0) err-zero-tokens)

    (if (is-eq (get-stx-balance) u0) 
      (first-provide-liquidity stx-amount max-token-amount tx-sender)
      (add-liquidity stx-amount)
    )
  )
)

;; Allow users to exchange STX and receive tokens at the current exchange rate
(define-public (stx-to-token-swap (stx-amount uint))
  (begin 
    (asserts! (> stx-amount u0) err-zero-stx)
    
    (let (
      (stx-balance (get-stx-balance))
      (moli-balance (get-moli-balance))
      ;; constant to maintain = STX * tokens
      (constant (* stx-balance moli-balance))
        ;; charge the fee. Fee is in basis points (1 = 0.01%), so divide by 10,000
      (fee (/ (* stx-amount fee-basis-points) u10000))
      (new-stx-balance (+ stx-balance stx-amount))
        ;; constant should = (new STX - fee) * new tokens
      (new-moli-balance (/ constant (- new-stx-balance fee)))
      ;; pay the difference between previous and new token balance to user
      (tokens-to-pay (- moli-balance new-moli-balance))
      ;; put addresses into variables for ease of use
      (user-address tx-sender)
      (contract-address (as-contract tx-sender))
    )
      (begin
        ;; transfer STX from user to contract
        (try! (stx-transfer? stx-amount user-address contract-address))
        ;; transfer tokens from contract to user
        (as-contract (contract-call? .moli-token transfer tokens-to-pay contract-address user-address))
      )
    )
  )
)
;; Allow users to exchange tokens and receive STX using the constant-product formula 
(define-public (token-to-stx-swap (token-amount uint) )
  (begin 
    (asserts! (> token-amount u0) err-zero-tokens)
    
    (let (
      (stx-balance (get-stx-balance))
      (moli-balance (get-moli-balance))
      ;; constant to maintain = STX * tokens
      (constant (* stx-balance moli-balance))
      ;; charge the fee. Fee is in basis points (1 = 0.01%), so divide by 10,000
      (fee (/ (* token-amount fee-basis-points) u10000))
      (new-moli-balance (+ moli-balance token-amount))
      ;; constant should = new STX * (new tokens - fee)
      (new-stx-balance (/ constant (- new-moli-balance fee)))
      ;; pay the difference between previous and new STX balance to user
      (stx-to-pay (- stx-balance new-stx-balance))
      ;; put addresses into variables for ease of use
      (user-address tx-sender)
      (contract-address (as-contract tx-sender))
    )
      (begin
       (print fee)
        (print new-moli-balance)
        (print (- new-moli-balance fee))
        (print new-stx-balance)
        (print stx-to-pay)
        ;; transfer tokens from user to contract
        (try! (contract-call? .moli-token transfer token-amount user-address contract-address))
        ;; transfer tokens from contract to user
        (as-contract (stx-transfer? stx-to-pay contract-address user-address))
      )
    )
  )
)


;; Anyone can remove liquidity by burning their LP tokens
;; in exchange for receiving their proportion of the STX and token balances
(define-public (remove-liquidity (liquidity-burned uint))
  (begin
    (asserts! (> liquidity-burned u0) err-zero-tokens)

      (let 
        (
            (stx-balance (get-stx-balance))
            (moli-balance (get-moli-balance))
            (liquidity-token-supply (contract-call? .moli-lp get-total-supply))

            ;; STX withdrawn = liquidity-burned * existing STX balance / total existing LP tokens
            ;; Tokens withdrawn = liquidity-burned * existing token balance / total existing LP tokens
            (stx-withdrawn (/ (* stx-balance liquidity-burned) liquidity-token-supply))
            (tokens-withdrawn (/ (* moli-balance liquidity-burned) liquidity-token-supply))

            (contract-address (as-contract tx-sender))
            (burner tx-sender)
        )
      (begin 
        ;; burn liquidity tokens as tx-sender
        (try! (contract-call? .moli-lp burn liquidity-burned))
        ;; transfer STX from contract to tx-sender
        (try! (as-contract (stx-transfer? stx-withdrawn contract-address burner)))
        ;; transfer tokens from contract to tx-sender
        (as-contract (contract-call? .moli-token transfer tokens-withdrawn contract-address burner))
      )
    )
  )
)

