;; moli-swap
;; <add a description here>


;;
;; 1i. get-moli-balance - return amount of moli tokens held by th contract
;;  - get the balance of moli tokens in the contract
;; 1ii. get-lima-balance - return amount of lima tokens held by th contract
;;  - get the balance of lima tokens in the contract
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
(define-constant err-zero-moli-tokens (err u201))
(define-constant err-zero-lima-tokens (err u202))
(define-constant fee-basis-points u30) ;; 0.3%

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

;; ;; Provide initial liquidity for STX/moli, which defines the initial exchange ratio for the STX/moli pair
;; (define-private (provide-first-moli-liquidity (stx-amount uint) (moli-amount uint) (provider principal) )
;;     (begin
;;       (try! (stx-transfer? stx-amount tx-sender (as-contract tx-sender)))
;;       (try! (contract-call? .moli-token transfer moli-amount tx-sender (as-contract tx-sender) ))
;;       (as-contract (contract-call? .moli-lp mint stx-amount provider))
;;     )
;; )

;; ;; Provide initial liquidity for STX/lima, which defines the initial exchange ratio for the STX/lima pair
;; (define-private (provide-first-lima-liquidity (stx-amount uint) (lima-amount uint) (provider principal))
;;     (begin
;;       (try! (stx-transfer? stx-amount tx-sender (as-contract tx-sender))) 
;;       (try! (contract-call? .lima-token transfer lima-amount tx-sender (as-contract tx-sender) ))
;;       (as-contract (contract-call? .moli-lp mint stx-amount provider))
;;     )
;; )

;; Provide initial liquidity for moli/lima, which defines the initial exchange ratio for the STX/lima pair
(define-private (provide-first-moli-lima-liquidity (moli-amount uint) (lima-amount uint) (provider principal))
    (begin
      (try! (contract-call? .moli-token transfer moli-amount tx-sender (as-contract tx-sender) ))
      (try! (contract-call? .lima-token transfer lima-amount tx-sender (as-contract tx-sender) ))
      (as-contract (contract-call? .moli-lp mint moli-amount provider))
    )
)

;; ;; Provide additional liquidity, that matches already set exchange ratio
;; (define-private ( add-moli-liquidity (stx-amount uint))
;;   (let (
;;           (contract-address (as-contract tx-sender))
;;           (stx-balance (get-stx-balance))
;;           (moli-balance (get-moli-balance))
;;           (moli-tokens-to-transfer (/ (* stx-amount moli-balance) stx-balance))
;;           (liquidity-token-supply (contract-call? .moli-lp get-total-supply))
;;           (liquidity-to-mint (/ (* stx-amount liquidity-token-supply) stx-balance))
;;           (provider tx-sender)
;;         )
;;     (begin 
;;       (try! (stx-transfer? stx-amount tx-sender contract-address))
;;       (try! (contract-call? .moli-token transfer moli-tokens-to-transfer tx-sender contract-address))
;;       (as-contract (contract-call? .moli-lp mint liquidity-to-mint provider))
;;     )
;;   )
;; )

;; ;; Provide additional liquidity, that matches already set exchange ratio
;; (define-private ( add-lima-liquidity (stx-amount uint))
;;   (let (
;;       ;; new tokens = additional STX * existing token balance / existing STX balance
;;           (contract-address (as-contract tx-sender))
;;           (stx-balance (get-stx-balance))
;;           (lima-balance (get-lima-balance))
;;           (lima-tokens-to-transfer (/ (* stx-amount lima-balance) stx-balance))
;;           (liquidity-token-supply (contract-call? .moli-lp get-total-supply))
;;           (liquidity-to-mint (/ (* stx-amount liquidity-token-supply) stx-balance))
;;           (provider tx-sender)
;;         )
;;     (begin 
;;           (try! (stx-transfer? stx-amount tx-sender contract-address))
;;           (try! (contract-call? .lima-token transfer lima-tokens-to-transfer tx-sender contract-address))
;;           (as-contract (contract-call? .moli-lp mint liquidity-to-mint provider))
;;     )
;;   )
;; )

;; Provide additional liquidity, that matches already set exchange ratio
(define-private ( add-moli-lima-liquidity (moli-amount uint))
  (let (
          (contract-address (as-contract tx-sender))
          (moli-balance (get-moli-balance))
          (lima-balance (get-lima-balance))
          (lima-tokens-to-transfer (/ (* moli-amount lima-balance) moli-balance))
          (liquidity-token-supply (contract-call? .moli-lp get-total-supply))
          (liquidity-to-mint (/ (* moli-amount liquidity-token-supply) moli-balance))
          (provider tx-sender)
        )
    (begin 
          (try! (contract-call? .moli-token transfer moli-amount tx-sender contract-address))
          (try! (contract-call? .lima-token transfer lima-tokens-to-transfer tx-sender contract-address))
          (as-contract (contract-call? .moli-lp mint liquidity-to-mint provider))
    )
  )
)

;; ;; function for proviing liquidity for STX/moli to the contract
;; (define-public (provide-moli-liquidity (stx-amount uint) (max-moli-amount uint))
;;   (begin
;;     (asserts! (> stx-amount u0) err-zero-stx)
;;     (asserts! (> max-moli-amount u0) err-zero-moli-tokens)

;;     (if (is-eq (get-stx-balance) u0) 
;;       (provide-first-moli-liquidity stx-amount max-moli-amount tx-sender)
;;       (add-moli-liquidity stx-amount)
;;     )
;;   )
;; )

;; ;; function for proviing liquidity for STX/lima to the contract
;; (define-public (provide-lima-liquidity (stx-amount uint) (max-lima-amount uint))
;;   (begin
;;     (asserts! (> stx-amount u0) err-zero-stx)
;;     (asserts! (> max-lima-amount u0) err-zero-moli-tokens)
;;     (if (is-eq (get-stx-balance) u0) 
;;       (provide-first-lima-liquidity stx-amount max-lima-amount tx-sender)
;;       (add-lima-liquidity stx-amount)
;;     )
;;   )
;; )

;; function for proviing liquidity for moli/lima to the contract
(define-public (provide-moli-lima-liquidity (moli-amount uint) (max-lima-amount uint))
  (begin
    (asserts! (> moli-amount u0) err-zero-stx)
    (asserts! (> max-lima-amount u0) err-zero-lima-tokens)
    (if (is-eq (get-moli-balance) u0) 
      (provide-first-moli-lima-liquidity moli-amount max-lima-amount tx-sender)
      (add-moli-lima-liquidity moli-amount)
    )
  )
)

;; ;; function for swaping STX/moli at the set exchange rate
;; (define-public (stx-to-moli-swap (stx-amount uint))
;;   (begin 
;;     (asserts! (> stx-amount u0) err-zero-stx)
;;     (let (
;;       (stx-balance (get-stx-balance))
;;       (moli-balance (get-moli-balance))
;;       (lima-balance (get-lima-balance))
;;       (constant (+ (* stx-balance moli-balance) (* stx-balance lima-balance)))
;;       (fee (/ (* stx-amount fee-basis-points) u10000))
;;       (new-stx-balance (+ stx-balance stx-amount))
;;       (new-moli-balance (/ constant (- new-stx-balance fee)))
;;       (moli-tokens-to-pay (- moli-balance new-moli-balance))
;;       (user-address tx-sender)
;;       (contract-address (as-contract tx-sender))
;;     )
;;       (begin
;;         (try! (stx-transfer? stx-amount user-address contract-address))
;;         (as-contract (contract-call? .moli-token transfer moli-tokens-to-pay contract-address user-address))
;;       )
;;     )
;;   )
;; )

;; ;; function for swaping STX/lima at the set exchange rate

;; (define-public (stx-to-lima-swap (stx-amount uint))
;;   (begin 
;;     (asserts! (> stx-amount u0) err-zero-stx)
;;     (let (
;;       (stx-balance (get-stx-balance))
;;       (moli-balance (get-moli-balance))
;;       (lima-balance (get-lima-balance))
;;       (constant (+ (* stx-balance moli-balance) (* stx-balance lima-balance)))
;;       (fee (/ (* stx-amount fee-basis-points) u10000))
;;       (new-stx-balance (+ stx-balance stx-amount))
;;       (new-lima-balance (/ constant (- new-stx-balance fee)))
;;       (lima-tokens-to-pay (- lima-balance new-lima-balance))
;;       (user-address tx-sender)
;;       (contract-address (as-contract tx-sender))
;;     )
;;       (begin
;;         (try! (stx-transfer? stx-amount user-address contract-address))
;;         (as-contract (contract-call? .lima-token transfer lima-tokens-to-pay contract-address user-address))
;;       )
;;     )
;;   )
;; )

;; ;; function for swaping moli/STX at the set exchange rate
;; (define-public (moli-to-stx-swap (moli-amount uint) )
;;   (begin 
;;     (asserts! (> moli-amount u0) err-zero-moli-tokens)
    
;;     (let (
;;       (stx-balance (get-stx-balance))
;;       (moli-balance (get-moli-balance))
;;       (constant (* stx-balance moli-balance))
;;       (fee (/ (* moli-amount fee-basis-points) u10000))
;;       (new-moli-balance (+ moli-balance moli-amount))
;;       (new-stx-balance (/ constant (- new-moli-balance fee)))
;;       (stx-to-pay (- stx-balance new-stx-balance))
;;       (user-address tx-sender)
;;       (contract-address (as-contract tx-sender))
;;     )
;;       (begin
;;        (print fee)
;;         (print new-moli-balance)
;;         (print (- new-moli-balance fee))
;;         (print new-stx-balance)
;;         (print stx-to-pay)
;;         ;; transfer tokens from user to contract
;;         (try! (contract-call? .moli-token transfer moli-amount user-address contract-address))
;;         ;; transfer tokens from contract to user
;;         (as-contract (stx-transfer? stx-to-pay contract-address user-address))
;;       )
;;     )
;;   )
;; )

;; ;; function for swaping lima/STX at the set exchange rate
;; (define-public (lima-to-stx-swap (lima-amount uint) )
;;   (begin 
;;     (asserts! (> lima-amount u0) err-zero-lima-tokens)
    
;;     (let (
;;       (stx-balance (get-stx-balance))
;;       (lima-balance (get-lima-balance))
;;       (constant (* stx-balance lima-balance))
;;       (fee (/ (* lima-amount fee-basis-points) u10000))
;;       (new-lima-balance (+ lima-balance lima-amount))
;;       (new-stx-balance (/ constant (- new-lima-balance fee)))
;;       (stx-to-pay (- stx-balance new-stx-balance))
;;       (user-address tx-sender)
;;       (contract-address (as-contract tx-sender))
;;     )
;;       (begin
;;        (print fee)
;;         (print new-lima-balance)
;;         (print (- new-lima-balance fee))
;;         (print new-stx-balance)
;;         (print stx-to-pay)
;;         (try! (contract-call? .lima-token transfer lima-amount user-address contract-address))
;;         (as-contract (stx-transfer? stx-to-pay contract-address user-address))
;;       )
;;     )
;;   )
;; )

;; function for swaping moli/lima at the set exchange rate
(define-public (moli-to-lima-swap (moli-amount uint) )
  (begin 
    (asserts! (> moli-amount u0) err-zero-moli-tokens)
    
    (let (
      (moli-balance (get-moli-balance))
      (lima-balance (get-lima-balance))
      (constant  (* moli-balance lima-balance)) ;; 4,000,000 
      (fee (/ (* moli-amount fee-basis-points) u10000))
      (new-moli-balance (+ moli-balance moli-amount))
      (new-lima-balance (/ constant (- new-moli-balance fee)))
      (lima-to-pay (- lima-balance new-lima-balance))
      (user-address tx-sender)
      (contract-address (as-contract tx-sender))
    )
      (begin
        ;; (print fee)
        ;; (print new-moli-balance)
        ;; (print (- new-moli-balance fee))
        ;; (print new-lima-balance)
        ;; (print lima-to-pay)
        (try! (contract-call? .moli-token transfer moli-amount user-address contract-address))
        (as-contract (contract-call? .lima-token transfer lima-to-pay contract-address user-address))
      )
    )
  )
)

;; function for swaping lima/moli at the set exchange rate
(define-public (lima-to-moli-swap (lima-amount uint) )
  (begin 
    (asserts! (> lima-amount u0) err-zero-lima-tokens)
    
    (let (
      (lima-balance (get-lima-balance))
      (moli-balance (get-moli-balance))
      (constant (* lima-balance moli-balance))
      (fee (/ (* lima-amount fee-basis-points) u10000))
      (new-lima-balance (+ lima-balance lima-amount))
      (new-moli-balance (/ constant (- new-lima-balance fee)))
      (moli-to-pay (- moli-balance new-moli-balance))
      (user-address tx-sender)
      (contract-address (as-contract tx-sender))
    )
      (begin
      ;;  (print fee)
      ;;   (print new-moli-balance)
      ;;   (print (- new-moli-balance fee))
      ;;   (print new-lima-balance)
      ;;   (print moli-to-pay)
        (try! (contract-call? .lima-token transfer lima-amount user-address contract-address) )
        (as-contract (contract-call? .moli-token transfer moli-to-pay contract-address user-address)))
      )
    )
  )


;; ;; function for Liquidity Providers to take profit by burning their moli-lp tokens

;; (define-public (remove-liquidity (liquidity-burned uint))
;;   (begin
;;     (asserts! (> liquidity-burned u0) err-zero-moli-tokens)

;;       (let 
;;         (
;;             (stx-balance (get-stx-balance))
;;             (moli-balance (get-moli-balance))
;;             (liquidity-token-supply (contract-call? .moli-lp get-total-supply))

;;             ;; STX withdrawn = liquidity-burned * existing STX balance / total existing LP tokens
;;             ;; Tokens withdrawn = liquidity-burned * existing token balance / total existing LP tokens
;;             (stx-withdrawn (/ (* stx-balance liquidity-burned) liquidity-token-supply))
;;             (tokens-withdrawn (/ (* moli-balance liquidity-burned) liquidity-token-supply))

;;             (contract-address (as-contract tx-sender))
;;             (burner tx-sender)
;;         )
;;       (begin 
;;         ;; burn liquidity tokens as tx-sender
;;         (try! (contract-call? .moli-lp burn liquidity-burned))
;;         ;; transfer STX from contract to tx-sender
;;         (try! (as-contract (stx-transfer? stx-withdrawn contract-address burner)))
;;         ;; transfer tokens from contract to tx-sender
;;         (as-contract (contract-call? .moli-token transfer tokens-withdrawn contract-address burner))
;;       )
;;     )
;;   )
;; )


;; function for Liquidity Providers to take profit by burning their moli-lp tokens
(define-public (remove-moli-liquidity (liquidity-burned uint))
  (begin
    (asserts! (> liquidity-burned u0) err-zero-moli-tokens)

      (let 
        (
            (moli-balance (get-moli-balance))
            (lima-balance (get-lima-balance))
            (liquidity-token-supply (contract-call? .moli-lp get-total-supply))
            (moli-withdrawn (/ (* moli-balance liquidity-burned) liquidity-token-supply))
            (lima-withdrawn (/ (* lima-balance liquidity-burned) liquidity-token-supply))
            (contract-address (as-contract tx-sender))
            (burner tx-sender)
        )
      (begin 
       
        (try! (contract-call? .moli-lp burn liquidity-burned))
        (try! (as-contract (contract-call? .moli-token transfer moli-withdrawn contract-address burner)))
        (as-contract (contract-call? .lima-token transfer lima-withdrawn contract-address burner))
      )
    )
  )
)
