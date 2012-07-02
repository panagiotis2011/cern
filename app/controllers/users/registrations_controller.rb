# encoding: utf-8
class Users::RegistrationsController < Devise::RegistrationsController
def update
		# η ιδιότητα lesson_id δεν έχει mass assignment (πρέπει να εμφανίζεται στο προφίλ μου) άρα την προστατεύουμε χειροκίνητα
		# έλεγχος για την ύπαρξη του lesson στην περίπτωση ενός κακόβουλου σπουδαστή που χειρίζεται τις παραμέτρους (fails silently)
		if params[resource_name][:lesson_id]
			resource.lesson_id = params[resource_name][:lesson_id] if Lesson.find_by_id(params[resource_name][:lesson_id])
		end
		if current_user.haslocalpw
			super
		else
			# αυτός ο λογαριασμός έχει δημιουργηθεί με τυχαίο password / ο σπουδαστής έχει εγγραφεί με υπηρεσίες δικτύωσης
			# εάν ο σπουδαστής δεν επιθυμεί να συμπληρώσει κάποιον κωδικό αφαιρούμε τις παραμέτρους για να αποτρέψουμε σφάλματα επικύρωσης
			if params[resource_name][:password].blank?
				params[resource_name].delete(:password)
				params[resource_name].delete(:password_confirmation) if params[resource_name][:password_confirmation].blank?
			else
				# εάν ο σπουδαστής επιθυμεί να συμπληρώσει κάποιον κωδικό
				params[resource_name][:haslocalpw] = true
			end
			# ο παρακάτω κώδικας έχει αντιγραφεί από τον devise controller, στη θέση του update_with_password χρησιμοποιούμε update_attributes
			if resource.update_attributes(params[resource_name])
				set_flash_message :notice, :updated
				sign_in resource_name, resource
				redirect_to after_update_path_for(resource)
			else
				clean_up_passwords(resource)
				render_with_scope :edit
			end
		end
	end
	def create
		if verify_recaptcha
			super
		else
			build_resource
			clean_up_passwords(resource)
			flash.now[:alert] = "Υπάρχει ένα σφάλμα με τον κωδικό recaptcha. Παρακαλώ ξαναπροσπαθήστε. [Κωδικός σφάλαμτος: " + flash[:recaptcha_error] + "]"
			flash.delete :recaptcha_error
			render :new
		end
	end
end
