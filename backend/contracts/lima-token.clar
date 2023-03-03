;; lima-token
;; <add a description here>

;; constants
;;
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u400))
(define-constant err-not-token-owner (err u401))

;; lima token would have no maximum supply!
(define-fungible-token lima)

;; return the token name
(define-read-only (get-name)
    (ok "lima Token")
)

;; return the token symbol
(define-read-only (get-symbol)
    (ok "lima")
)

;; return the decimals of the token
(define-read-only (get-decimals)
    (ok u6)
)

;; return te token balance
(define-read-only (get-balance (who principal))
  (ft-get-balance lima who)
)


;; return the total supply of the lima token
(define-read-only (get-total-supply)
    (ok (ft-get-supply lima))
)


;; return the link to the metadata of the lima token assets
(define-read-only (get-token-uri)
    (ok none)
)


;; public functions

;; transfer function 
;; sample call (contract-call? .lima-token transfer u500 tx-sender 'STNHKEPYEPJ8ET55ZZ0M5A34J0R3N5FM2CMMMAZ6 (some 0x123456) ) (memo (optional (buff 34)))
(define-public (transfer (amount uint) (sender principal) (recipient principal) )
    (begin
        (asserts! (is-eq tx-sender sender) err-not-token-owner)
                ;; #[filter(amount, recipient)]
        (try! (ft-transfer? lima amount sender recipient))
        ;; (match memo to-print (print to-print) 0x)
        (ok true)
    )
)

;; mint a token
(define-public (mint (amount uint) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
                ;; #[filter(amount, recipient)]
        (ft-mint? lima amount recipient)
    )
)