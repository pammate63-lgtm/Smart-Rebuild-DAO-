(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-member (err u101))
(define-constant err-already-member (err u102))
(define-constant err-insufficient-funds (err u103))
(define-constant err-project-not-found (err u104))
(define-constant err-already-voted (err u105))
(define-constant err-voting-closed (err u106))
(define-constant err-invalid-amount (err u107))
(define-constant err-project-not-approved (err u108))
(define-constant err-invalid-status (err u109))
(define-constant err-already-funded (err u110))
(define-constant err-invalid-category (err u111))

(define-data-var next-member-id uint u1)
(define-data-var next-project-id uint u1)
(define-data-var next-proposal-id uint u1)
(define-data-var dao-treasury uint u0)
(define-data-var total-members uint u0)
(define-data-var membership-fee uint u50000)
(define-data-var min-proposal-amount uint u100000)
(define-data-var voting-period uint u1440)

(define-map members principal {
    id: uint,
    name: (string-ascii 256),
    location: (string-ascii 128),
    reputation-score: uint,
    join-block: uint,
    active: bool,
    total-contributions: uint,
    projects-completed: uint
})

(define-map member-votes {member: principal, proposal-id: uint} bool)

(define-map rebuild-projects uint {
    id: uint,
    title: (string-ascii 256),
    description: (string-ascii 512),
    category: (string-ascii 64),
    location: (string-ascii 128),
    requested-amount: uint,
    current-funding: uint,
    project-owner: principal,
    status: (string-ascii 32),
    created-block: uint,
    deadline-block: uint,
    approved: bool,
    completed: bool,
    beneficiaries: uint,
    priority-level: uint
})

(define-map funding-proposals uint {
    id: uint,
    project-id: uint,
    title: (string-ascii 256),
    description: (string-ascii 512),
    amount-requested: uint,
    proposer: principal,
    created-block: uint,
    voting-end-block: uint,
    yes-votes: uint,
    no-votes: uint,
    executed: bool,
    approved: bool
})

(define-map project-updates uint {
    project-id: uint,
    update-text: (string-ascii 512),
    reporter: principal,
    timestamp: uint,
    funding-used: uint
})

(define-map disaster-reports uint {
    id: uint,
    reporter: principal,
    location: (string-ascii 128),
    disaster-type: (string-ascii 64),
    severity: uint,
    affected-population: uint,
    estimated-damage: uint,
    description: (string-ascii 512),
    verified: bool,
    report-block: uint
})

(define-data-var next-report-id uint u1)
(define-data-var next-update-id uint u1)

(define-public (register-member (name (string-ascii 256)) (location (string-ascii 128)))
    (let ((member-id (var-get next-member-id)))
        (asserts! (is-none (map-get? members tx-sender)) err-already-member)
        (try! (stx-transfer? (var-get membership-fee) tx-sender (as-contract tx-sender)))
        (map-set members tx-sender {
            id: member-id,
            name: name,
            location: location,
            reputation-score: u100,
            join-block: stacks-block-height,
            active: true,
            total-contributions: (var-get membership-fee),
            projects-completed: u0
        })
        (var-set next-member-id (+ member-id u1))
        (var-set total-members (+ (var-get total-members) u1))
        (var-set dao-treasury (+ (var-get dao-treasury) (var-get membership-fee)))
        (ok member-id)
    )
)

(define-public (create-rebuild-project 
    (title (string-ascii 256))
    (description (string-ascii 512))
    (category (string-ascii 64))
    (location (string-ascii 128))
    (requested-amount uint)
    (deadline-blocks uint)
    (beneficiaries uint)
    (priority-level uint)
)
    (let ((project-id (var-get next-project-id)))
        (asserts! (is-some (map-get? members tx-sender)) err-not-member)
        (asserts! (> requested-amount u0) err-invalid-amount)
        (asserts! (<= priority-level u5) err-invalid-status)
        (map-set rebuild-projects project-id {
            id: project-id,
            title: title,
            description: description,
            category: category,
            location: location,
            requested-amount: requested-amount,
            current-funding: u0,
            project-owner: tx-sender,
            status: "pending",
            created-block: stacks-block-height,
            deadline-block: (+ stacks-block-height deadline-blocks),
            approved: false,
            completed: false,
            beneficiaries: beneficiaries,
            priority-level: priority-level
        })
        (var-set next-project-id (+ project-id u1))
        (ok project-id)
    )
)

(define-public (create-funding-proposal 
    (project-id uint)
    (title (string-ascii 256))
    (description (string-ascii 512))
    (amount-requested uint)
)
    (let ((proposal-id (var-get next-proposal-id))
          (project (unwrap! (map-get? rebuild-projects project-id) err-project-not-found)))
        (asserts! (is-some (map-get? members tx-sender)) err-not-member)
        (asserts! (>= amount-requested (var-get min-proposal-amount)) err-invalid-amount)
        (map-set funding-proposals proposal-id {
            id: proposal-id,
            project-id: project-id,
            title: title,
            description: description,
            amount-requested: amount-requested,
            proposer: tx-sender,
            created-block: stacks-block-height,
            voting-end-block: (+ stacks-block-height (var-get voting-period)),
            yes-votes: u0,
            no-votes: u0,
            executed: false,
            approved: false
        })
        (var-set next-proposal-id (+ proposal-id u1))
        (ok proposal-id)
    )
)

(define-public (vote-on-proposal (proposal-id uint) (vote-for bool))
    (let ((proposal (unwrap! (map-get? funding-proposals proposal-id) err-project-not-found))
          (member (unwrap! (map-get? members tx-sender) err-not-member)))
        (asserts! (< stacks-block-height (get voting-end-block proposal)) err-voting-closed)
        (asserts! (is-none (map-get? member-votes {member: tx-sender, proposal-id: proposal-id})) err-already-voted)
        (map-set member-votes {member: tx-sender, proposal-id: proposal-id} vote-for)
        (if vote-for
            (map-set funding-proposals proposal-id (merge proposal {yes-votes: (+ (get yes-votes proposal) u1)}))
            (map-set funding-proposals proposal-id (merge proposal {no-votes: (+ (get no-votes proposal) u1)}))
        )
        (ok vote-for)
    )
)

(define-public (execute-proposal (proposal-id uint))
    (let ((proposal (unwrap! (map-get? funding-proposals proposal-id) err-project-not-found))
          (project-id (get project-id proposal))
          (project (unwrap! (map-get? rebuild-projects project-id) err-project-not-found)))
        (asserts! (>= stacks-block-height (get voting-end-block proposal)) err-voting-closed)
        (asserts! (not (get executed proposal)) err-already-funded)
        (let ((approved (> (get yes-votes proposal) (get no-votes proposal))))
            (map-set funding-proposals proposal-id (merge proposal {
                executed: true,
                approved: approved
            }))
            (if approved
                (begin
                    (map-set rebuild-projects project-id (merge project {
                        approved: true,
                        current-funding: (+ (get current-funding project) (get amount-requested proposal)),
                        status: "funded"
                    }))
                    (var-set dao-treasury (- (var-get dao-treasury) (get amount-requested proposal)))
                    (try! (as-contract (stx-transfer? (get amount-requested proposal) tx-sender (get project-owner project))))
                    (ok true)
                )
                (ok false)
            )
        )
    )
)

(define-public (contribute-to-treasury (amount uint))
    (begin
        (asserts! (is-some (map-get? members tx-sender)) err-not-member)
        (asserts! (> amount u0) err-invalid-amount)
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (var-set dao-treasury (+ (var-get dao-treasury) amount))
        (let ((member (unwrap! (map-get? members tx-sender) err-not-member)))
            (map-set members tx-sender (merge member {
                total-contributions: (+ (get total-contributions member) amount),
                reputation-score: (+ (get reputation-score member) (/ amount u1000))
            }))
        )
        (ok amount)
    )
)

(define-public (report-disaster 
    (location (string-ascii 128))
    (disaster-type (string-ascii 64))
    (severity uint)
    (affected-population uint)
    (estimated-damage uint)
    (description (string-ascii 512))
)
    (let ((report-id (var-get next-report-id)))
        (asserts! (is-some (map-get? members tx-sender)) err-not-member)
        (asserts! (<= severity u10) err-invalid-status)
        (map-set disaster-reports report-id {
            id: report-id,
            reporter: tx-sender,
            location: location,
            disaster-type: disaster-type,
            severity: severity,
            affected-population: affected-population,
            estimated-damage: estimated-damage,
            description: description,
            verified: false,
            report-block: stacks-block-height
        })
        (var-set next-report-id (+ report-id u1))
        (ok report-id)
    )
)

(define-public (verify-disaster-report (report-id uint))
    (let ((report (unwrap! (map-get? disaster-reports report-id) err-project-not-found)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set disaster-reports report-id (merge report {verified: true}))
        (ok true)
    )
)

(define-public (update-project-progress 
    (project-id uint)
    (update-text (string-ascii 512))
    (funding-used uint)
)
    (let ((project (unwrap! (map-get? rebuild-projects project-id) err-project-not-found))
          (update-id (var-get next-update-id)))
        (asserts! (is-some (map-get? members tx-sender)) err-not-member)
        (map-set project-updates update-id {
            project-id: project-id,
            update-text: update-text,
            reporter: tx-sender,
            timestamp: stacks-block-height,
            funding-used: funding-used
        })
        (var-set next-update-id (+ update-id u1))
        (ok update-id)
    )
)

(define-public (complete-project (project-id uint))
    (let ((project (unwrap! (map-get? rebuild-projects project-id) err-project-not-found)))
        (asserts! (is-eq tx-sender (get project-owner project)) err-owner-only)
        (asserts! (get approved project) err-project-not-approved)
        (map-set rebuild-projects project-id (merge project {
            completed: true,
            status: "completed"
        }))
        (let ((member (unwrap! (map-get? members tx-sender) err-not-member)))
            (map-set members tx-sender (merge member {
                projects-completed: (+ (get projects-completed member) u1),
                reputation-score: (+ (get reputation-score member) u50)
            }))
        )
        (ok true)
    )
)

(define-public (deactivate-member (member-principal principal))
    (let ((member (unwrap! (map-get? members member-principal) err-not-member)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set members member-principal (merge member {active: false}))
        (ok true)
    )
)

(define-read-only (get-member (member-principal principal))
    (map-get? members member-principal)
)

(define-read-only (get-project (project-id uint))
    (map-get? rebuild-projects project-id)
)

(define-read-only (get-proposal (proposal-id uint))
    (map-get? funding-proposals proposal-id)
)

(define-read-only (get-disaster-report (report-id uint))
    (map-get? disaster-reports report-id)
)

(define-read-only (get-project-update (update-id uint))
    (map-get? project-updates update-id)
)

(define-read-only (get-dao-stats)
    (ok {
        treasury: (var-get dao-treasury),
        total-members: (var-get total-members),
        membership-fee: (var-get membership-fee),
        min-proposal-amount: (var-get min-proposal-amount),
        voting-period: (var-get voting-period),
        next-project-id: (var-get next-project-id),
        next-proposal-id: (var-get next-proposal-id),
        next-report-id: (var-get next-report-id)
    })
)

(define-read-only (get-member-vote (member-principal principal) (proposal-id uint))
    (map-get? member-votes {member: member-principal, proposal-id: proposal-id})
)

(define-read-only (get-active-projects)
    (ok {
        pending-projects: (- (var-get next-project-id) u1),
        active-proposals: (- (var-get next-proposal-id) u1),
        disaster-reports: (- (var-get next-report-id) u1)
    })
)