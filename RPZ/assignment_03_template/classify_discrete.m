function labels = classify_discrete(img, q)

features = compute_measurement_lr_discrete(img) + 11;
labels = q(features');
