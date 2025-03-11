;; asset-registration.clar
;; This contract tracks public infrastructure components

(define-map assets
  { asset-id: uint }
  {
    name: (string-ascii 64),
    asset-type: (string-ascii 32),
    location: (string-ascii 128),
    installation-date: uint,
    last-maintenance: uint,
    status: (string-ascii 16)
  }
)

(define-data-var last-asset-id uint u0)

(define-read-only (get-asset (asset-id uint))
  (map-get? assets { asset-id: asset-id })
)

(define-public (register-asset (name (string-ascii 64)) (asset-type (string-ascii 32)) (location (string-ascii 128)))
  (let
    (
      (new-asset-id (+ (var-get last-asset-id) u1))
    )
    (var-set last-asset-id new-asset-id)
    (ok (map-set assets
      { asset-id: new-asset-id }
      {
        name: name,
        asset-type: asset-type,
        location: location,
        installation-date: block-height,
        last-maintenance: block-height,
        status: "operational"
      }
    ))
  )
)

(define-public (update-asset-status (asset-id uint) (new-status (string-ascii 16)))
  (let
    (
      (asset (unwrap! (get-asset asset-id) (err u404)))
    )
    (ok (map-set assets
      { asset-id: asset-id }
      (merge asset { status: new-status })
    ))
  )
)

(define-public (update-last-maintenance (asset-id uint))
  (let
    (
      (asset (unwrap! (get-asset asset-id) (err u404)))
    )
    (ok (map-set assets
      { asset-id: asset-id }
      (merge asset { last-maintenance: block-height })
    ))
  )
)

