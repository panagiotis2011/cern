# encoding: utf-8
# μετά από κάθε αλλαγή αυτού του αρχείου απαιτείται επανεκκίνηση του server
ActiveSupport::Inflector.inflections do |inflect|
	inflect.plural /^(ox)$/i, '\1\2en'
	inflect.singular /^(ox)en/i, '\1'
	inflect.irregular 'Πρόχειρη ερώτηση', 'Πρόχειρες ερωτήσεις'
	inflect.irregular 'Άσκηση', 'Ασκήσεις'
	inflect.irregular 'Ερώτηση προς υποβολή', 'Ερωτήσεις προς υποβολή'
	inflect.irregular 'Μη αποδεκτή ερώτηση', 'Μη αποδεκτές ερωτήσεις'
	inflect.irregular 'Ολοκληρωμένη ερώτηση', 'Ολοκληρωμένες ερωτήσεις'
	inflect.irregular 'Προτεινόμενη ερώτηση', 'Προτεινόμενες ερωτήσεις'
	inflect.irregular 'Δημοσιευμένη ερώτηση', 'Δημοσιευμένες ερωτήσεις'
	inflect.irregular 'Χρήστης', 'Χρήστες'
	inflect.irregular 'Φοιτητής', 'Φοιτητές'
	inflect.irregular 'Καθηγητής', 'Καθηγητές'
	inflect.irregular 'Φοιτητής χρησιμοποίησε', 'Φοιτητές χρησιμοποίησαν'
	inflect.irregular 'Φοιτητής έχει', 'Φοιτητές έχουν'
	inflect.irregular 'λάθος δεν επιτρέπει', 'λάθη δεν επιτρέπουν'
	inflect.irregular 'σφάλμα', 'σφάλματα'
	inflect.irregular 'ψήφο', 'ψήφους'
end
