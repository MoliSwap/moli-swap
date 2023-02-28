
;; ;; moli-swap
;; ;; <add a description here>


;; ;;
;; ;; 1. getReserve() - return amount of moli tokens held by th contract
;; ;;  - get the balance of moli tokens in the contract
;; ;; 2. addLiquidity(_amount) - add liquidity to the pool of STX/moli
;; ;;  - define a variable liquidity
;; ;;  - get the STX balance and save inside stxBalance variable
;; ;;  - get the STX in the contract
;; ;; 3. removeLiquidity() - returns the amount of STX/moli to be returned to the user
;; ;; 4. getAmountOfToken() - return the amount of STX/moli tha would be returned to a user in a swap
;; ;;  -   the amount of STX/moli to be returned to the user in a swap
;; ;; 5. stxToMoliToken() - swap STX for moli tokens
;; ;; 6. moliToStx() - swap moli tokens to stx
;; ;;
;; ;; add-liquidity
;; ;; (define-constant err-zero-stx (err u200))
;; ;; (define-constant err-zero-tokens (err u201))

;; ;; (define-public (add-liquidity (stx-amount uint) (max-token-amount uint) (memo (optional (buff 34))))
;; ;;   (begin
;; ;;     (asserts! (> stx-amount u0) err-zero-stx)
;; ;;     (asserts! (> max-token-amount u0) err-zero-tokens)

;; ;;     ;; send STX from tx-sender to the contract
;; ;;     (try! (stx-transfer? stx-amount tx-sender (as-contract tx-sender)))
;; ;;     ;; send tokens from tx-sender to the contract
;; ;;     ;; sample transaction call (contract-call? .moli-token transfer u500 tx-sender 'STNHKEPYEPJ8ET55ZZ0M5A34J0R3N5FM2CMMMAZ6 (some 0x123456) )
;; ;;     (contract-call? .moli-token transfer max-token-amount tx-sender (as-contract tx-sender) (some 0x123456))
;; ;;   )
;; ;; )

;; (define-constant err-zero-stx (err u200))
;; (define-constant err-zero-tokens (err u201))

;; ;; Get contract STX balance
;; (define-private (get-stx-balance)
;;   (stx-get-balance (as-contract tx-sender))
;; )

;; ;; Get contract token balance
;; (define-private (get-token-balance)
;;   (contract-call? .moli-token get-balance (as-contract tx-sender))
;; )

;; ;; Provide initial liquidity, defining the initial exchange ratio
;; (define-private (provide-liquidity (stx-amount uint) (token-amount uint) (memo (optional (buff 34))))
;;     (begin
;;       ;; send STX from tx-sender to the contract
;;       (try! (stx-transfer? stx-amount tx-sender (as-contract tx-sender)))
;;       ;; send tokens from tx-sender to the contract
;;       ;; sample transaction call (contract-call? .moli-token transfer u500 tx-sender 'STNHKEPYEPJ8ET55ZZ0M5A34J0R3N5FM2CMMMAZ6 (some 0x123456) )
;;     (contract-call? .moli-token transfer token-amount tx-sender (as-contract tx-sender) (some 0x123456))
;;     )
;; )

;; ;; Provide additional liquidity, matching the current ratio
;; ;; We don't have a max token amount, that's handled by post-conditions
;; (define-private (add-liquidity (stx-amount uint))
;;   (let (
;;       ;; new tokens = additional STX * existing token balance / existing STX balance
;;       (contract-address (as-contract tx-sender))
;;       (token-balance (get-token-balance))
;;       (tokens-to-transfer (/ (* stx-amount token-balance) (get-stx-balance)))
;;     )
;;     (begin 
;;       ;; transfer STX from liquidity provider to contract
;;       (try! (stx-transfer? stx-amount tx-sender contract-address))
;;       ;; transfer tokens from liquidity provider to contract
;;       (contract-call? .moli-token transfer tokens-to-transfer tx-sender contract-address)
;;     )
;;   )
;; )

;; ;; Anyone can provide liquidity by transferring STX and tokens to the contract
;; (define-public (provide-liquidity (stx-amount uint) (max-token-amount uint))
;;   (begin
;;     (asserts! (> stx-amount u0) err-zero-stx)
;;     (asserts! (> max-token-amount u0) err-zero-tokens)

;;     (if (is-eq (get-stx-balance) u0) 
;;       (provide-liquidity stx-amount max-token-amount)
;;       (add-liquidity stx-amount)
;;     )
;;   )
;; )

;; ;; Allow users to exchange STX and receive tokens at the current exchange rate
;; (define-public (stx-to-token-swap (stx-amount uint))
;;   (begin 
;;     (asserts! (> stx-amount u0) err-zero-stx)
    
;;     (let (
;;       (stx-balance (get-stx-balance))
;;       (token-balance (get-token-balance))
;;       ;; constant to maintain = STX * tokens
;;       (constant (* stx-balance token-balance))
;;       (new-stx-balance (+ stx-balance stx-amount))
;;       ;; constant should = new STX * new tokens
;;       (new-token-balance (/ constant new-stx-balance))
;;       ;; pay the difference between previous and new token balance to user
;;       (tokens-to-pay (- token-balance new-token-balance))
;;       ;; put addresses into variables for ease of use
;;       (user-address tx-sender)
;;       (contract-address (as-contract tx-sender))
;;     )
;;       (begin
;;         ;; transfer STX from user to contract
;;         (try! (stx-transfer? stx-amount user-address contract-address))
;;         ;; transfer tokens from contract to user
;;         (as-contract (contract-call? .moli-token transfer tokens-to-pay contract-address user-address))
;;       )
;;     )
;;   )
;; )
;; ;; Allow users to exchange tokens and receive STX using the constant-product formula
;; (define-public (token-to-stx-swap (token-amount uint) (memo (optional (buff 34))))
;;   (begin 
;;     (asserts! (> token-amount u0) err-zero-tokens)
    
;;     (let (
;;       (stx-balance (get-stx-balance))
;;       (token-balance (get-token-balance))
;;       ;; constant to maintain = STX * tokens
;;       (constant (* stx-balance token-balance))
;;       (new-token-balance (+ token-balance token-amount))
;;       ;; constant should = new STX * new tokens
;;       (new-stx-balance (/ constant new-token-balance))
;;       ;; pay the difference between previous and new STX balance to user
;;       (stx-to-pay (- stx-balance new-stx-balance))
;;       ;; put addresses into variables for ease of use
;;       (user-address tx-sender)
;;       (contract-address (as-contract tx-sender))
;;     )
;;       (begin
;;         ;; transfer tokens from user to contract
;;         (try! (contract-call? .moli-token transfer token-amount user-address contract-address  (some 0x123456)))
;;         ;; transfer tokens from contract to user
;;         (as-contract (stx-transfer? stx-to-pay contract-address user-address))
;;       )
;;     )
;;   )
;; )