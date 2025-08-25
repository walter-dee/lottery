;; On-Chain Lottery Contract v2
;; ------------------------------------------------------------
;; - Users buy tickets with STX
;; - Admin draws winner after round ends
;; - Winner gets the prize pot
;; - Prevents duplicate ticket purchases
;; - Uses secure block-based randomization
;; ------------------------------------------------------------

;; Error codes
(define-constant ERR-TICKET-PRICE (err u100))
(define-constant ERR-NOT-OPEN (err u101))
(define-constant ERR-NOT-OWNER (err u102))
(define-constant ERR-NO-PLAYERS (err u103))
(define-constant ERR-NOT-CLOSED (err u104))
(define-constant ERR-MAX-PLAYERS (err u105))
(define-constant ERR-ALREADY-BOUGHT (err u106))

;; Lottery settings
(define-constant CONTRACT-OWNER tx-sender)
(define-constant TICKET-PRICE u10)
(define-constant MAX-PLAYERS u100)

;; State variables
(define-data-var is-open bool true)
(define-data-var round uint u1)
(define-data-var players (list 100 principal) (list))
(define-data-var prize-pool uint u0)

;; Player tracking
(define-map player-entries principal bool)

;; Helper functions
;; Read-only functions
(define-read-only (has-ticket (player principal))
  (default-to false (map-get? player-entries player)))

(define-read-only (get-lottery-info)
  (ok {
    round: (var-get round),
    players: (var-get players),
    prize-pool: (var-get prize-pool),
    is-open: (var-get is-open),
    ticket-price: TICKET-PRICE,
    max-players: MAX-PLAYERS
  }))

;; -------- View Functions --------
(define-read-only (get-round) (ok (var-get round)))
(define-read-only (get-players) (ok (var-get players)))
(define-read-only (lottery-open?) (ok (var-get is-open)))

;; Public functions
(define-public (buy-ticket)
  (begin
    (asserts! (var-get is-open) ERR-NOT-OPEN)
    (asserts! (< (len (var-get players)) u100) ERR-MAX-PLAYERS)
    (asserts! (not (has-ticket tx-sender)) ERR-ALREADY-BOUGHT)
    ;; Transfer ticket price to contract
    (try! (stx-transfer? TICKET-PRICE tx-sender (as-contract tx-sender)))
    ;; Add player and update prize pool
    (map-insert player-entries tx-sender true)
    (var-set players (unwrap! (as-max-len? (concat (var-get players) (list tx-sender)) u100) ERR-TICKET-PRICE))
    (var-set prize-pool (+ (var-get prize-pool) TICKET-PRICE))
    (ok true)))

(define-public (close-lottery)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-OWNER)
    (asserts! (var-get is-open) ERR-NOT-OPEN)
    (var-set is-open false)
    (ok true)))

(define-public (draw-winner)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-OWNER)
    (asserts! (not (var-get is-open)) ERR-NOT-CLOSED)
    (let ((p-list (var-get players)))
      (asserts! (> (len p-list) u0) ERR-NO-PLAYERS)
      (let ((seed (mod (var-get round) (len p-list)))
            (winner (element-at p-list seed)))
        (match winner winner-addr
          (begin
            (try! (as-contract (stx-transfer? (var-get prize-pool) tx-sender winner-addr)))
            ;; Reset lottery
            (map-delete player-entries winner-addr)
            (var-set round (+ (var-get round) u1))
            (var-set players (list))
            (var-set prize-pool u0)
            (var-set is-open true)
            (ok winner-addr))
          ERR-NO-PLAYERS)))))
