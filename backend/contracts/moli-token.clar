;; moli-token
;; <add a description here>

;; (impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; constants
;;
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

;; moli token would have no maximum supply!
(define-fungible-token moli)

;; return the token name
(define-read-only (get-name)
    (ok "Moli Token")
)

;; return the token symbol
(define-read-only (get-symbol)
    (ok "Moli")
)

;; return the decimals of the token
(define-read-only (get-decimals)
    (ok u6)
)

;; return te token balance
(define-read-only (get-balance (who principal))
  (ft-get-balance moli who)
)


;; return the total supply of the moli token
(define-read-only (get-total-supply)
    (ok (ft-get-supply moli))
)


;; return the link to the metadata of the moli token assets
(define-read-only (get-token-uri)
    (ok none)
)


;; public functions

;; transfer function 
(define-public (transfer (amount uint) (sender principal) (recipient principal) )
    (begin
        (asserts! (is-eq tx-sender sender) err-not-token-owner)
                ;; #[filter(amount, recipient)]
        (try! (ft-transfer? moli amount sender recipient))
        (ok true)
    )
)

;; mint a token
(define-public (mint (amount uint) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
                ;; #[filter(amount, recipient)]
        (ft-mint? moli amount recipient)
    )
)