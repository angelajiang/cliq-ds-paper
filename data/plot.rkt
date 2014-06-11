#lang racket

(require json
         plot)

(define data (read-json (open-input-file "tag_popularity_v1.json")))

(define (votes js)
  (hash-ref (hash-ref js 'top) 'votes))
(define (max-votes js)
  (hash-ref (votes js) 'max))
(define (mean-votes js)
  (hash-ref (votes js) 'mean))
(define (views js)
  (hash-ref (hash-ref js 'views) 'day))
(define (subs js)
  (hash-ref js 'subscribers))
(define (:+: f g)
  (λ (x)
    (+ (f x) (g x))))

(define with-views 
  (for/hash ([(k v) (in-hash data)]
             #:unless (symbol? (views v)))
    (values k v)))

(define (plot-by data attr #:transforms [transforms (list (vector id-transform id-transform))])
  (define extracted
    (sort (for/list ([(subreddit vals) (in-hash (hash-remove  data 'promos))])
            #;#;(displayln subreddit)
            (displayln vals)
            (cons subreddit (attr vals)))
          >
          #:key cdr))
  (define pts
    (points (for/list ([i (in-naturals)]
                             [pr (in-list extracted)])
                    (vector (+ 1 i) (cdr pr)))))
  (for/list ([xyt (in-list transforms)])
    (define xt (vector-ref xyt 0))
    (define yt (vector-ref xyt 1))
    (parameterize ([plot-x-transform xt]
                   [plot-y-transform yt])
      (plot pts))))
(define t-options
  `(#(,id-transform ,id-transform)
    #(,log-transform ,id-transform)
    #(,id-transform ,log-transform)
    #(,log-transform ,log-transform)))

(plot-by with-views views #:transforms t-options)
(plot-by data subs #:transforms t-options)
(plot-by data mean-votes #:transforms t-options)
(plot-by with-views (views . :+: . mean-votes) #:transforms t-options)

(define (to-arr-hash l)
  (for/hash ([i (in-naturals)]
             [x (in-list l)])
    (values x i)))
(define by-views (to-arr-hash (map car (sort (hash->list with-views) > #:key (compose views cdr)))))
(define by-votes (to-arr-hash (map car (sort (hash->list with-views) > #:key (compose mean-votes cdr)))))
(plot (points
       (for/list ([(k views) (in-hash by-views)])
         (vector views (hash-ref by-votes k)))))
(parameterize ([plot-x-transform log-transform] [plot-y-transform log-transform])
  (plot (points
         (for/list ([(k v) (in-hash with-views)])
           (vector (views v)
                   (mean-votes v))))))
(define both-log-views-votes 
  (parameterize ([plot-x-transform log-transform] [plot-y-transform log-transform])
  (plot (points
         (for/list ([(k v) (in-hash with-views)])
           (vector (views v)
                   (mean-votes v)))))))
(define x-log-views-votes(parameterize ([plot-x-transform log-transform])
  (plot (points
         (for/list ([(k v) (in-hash with-views)])
           (vector (views v)
                   (mean-votes v)))))))
(list both-log-views-votes x-log-views-votes)

(define log-log-views-votes-scatter-plot
  (parameterize ([plot-x-transform log-transform] 
                 [plot-y-transform log-transform])
    (plot #:x-label "log(Average Views/Day)"
          #:y-label "log(Average Votes/Top Submission of All Time)"
     (points
           (for/list ([(k v) (in-hash with-views)])
             (vector (views v)
                     (mean-votes v)))))))