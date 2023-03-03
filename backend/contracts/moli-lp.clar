;; moli-lp
;; <add a description here>

(define-fungible-token moli-lp)


;; constants
;;

(define-constant err-minter-only (err u300))
(define-constant err-amount-zero (err u301))

;; data maps and vars
;;
(define-data-var allowed-minter principal tx-sender)
;; private functions
;;

;; public functions
;;
;; return the token total supply
(define-read-only (get-total-supply)
  (ft-get-supply moli-lp)
)

;; Change the minter to any other principal, can only be called the current minter
(define-public (set-minter (who principal))
  (begin
    (asserts! (is-eq tx-sender (var-get allowed-minter)) err-minter-only)
    ;; who is unchecked, we allow the minter to make whoever they like the new minter
    ;; #[allow(unchecked_data)]
    (ok (var-set allowed-minter who))
  )
)

;; Custom function to mint tokens, only available to our exchange
(define-public (mint (amount uint) (who principal))
  (begin
    (asserts! (is-eq tx-sender (var-get allowed-minter)) err-minter-only)
    (asserts! (> amount u0) err-amount-zero)
    ;; amount, who are unchecked, but we let the contract owner mint to whoever they like for convenience
    ;; #[allow(unchecked_data)]
    (ft-mint? moli-lp amount who)
  )
)

;; return the token decimal
(define-read-only (get-decimals) 
  (ok u6)
)
;; return the token symboll
(define-read-only (get-symbol)
  (ok "Moli-LP")
)

;; return the token name
(define-read-only (get-name)
    (ok "Moli LP Token")
)

;; Any user can burn any amount of their own tokens
(define-public (burn (amount uint))
  (ft-burn? moli-lp amount tx-sender)
)