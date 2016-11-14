function label = classify_2normal(imgs, q)

features = compute_measurement_lr_cont(imgs);
label = ones(1, length(imgs));
label(features < q.t1) = q.decision(1);
label((features >= q.t1) & (features < q.t2)) = q.decision(2);
label(features >= q.t2) = q.decision(3);
