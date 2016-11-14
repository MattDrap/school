function error = classification_error_2normal(images, labels, q)

error = sum(labels ~= classify_2normal(images, q))/length(labels)
