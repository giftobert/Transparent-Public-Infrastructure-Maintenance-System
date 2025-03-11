;; contractor-verification.clar
;; This contract ensures qualified entities perform work

(define-map contractors
  { contractor: principal }
  {
    name: (string-ascii 64),
    specialization: (string-ascii 32),
    certification-expiry: uint,
    rating: uint
  }
)

(define-constant contract-owner tx-sender)

(define-read-only (get-contractor (contractor principal))
  (map-get? contractors { contractor: contractor })
)

(define-public (register-contractor (name (string-ascii 64)) (specialization (string-ascii 32)) (certification-expiry uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u403))
    (ok (map-set contractors
      { contractor: tx-sender }
      {
        name: name,
        specialization: specialization,
        certification-expiry: certification-expiry,
        rating: u0
      }
    ))
  )
)

(define-public (update-contractor-rating (contractor principal) (new-rating uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u403))
    (asserts! (<= new-rating u5) (err u400))
    (let
      (
        (contractor-info (unwrap! (get-contractor contractor) (err u404)))
      )
      (ok (map-set contractors
        { contractor: contractor }
        (merge contractor-info { rating: new-rating })
      ))
    )
  )
)

(define-read-only (is-contractor-verified (contractor principal))
  (match (get-contractor contractor)
    contractor-info (and
      (>= (get certification-expiry contractor-info) block-height)
      (> (get rating contractor-info) u0)
    )
    false
  )
)

