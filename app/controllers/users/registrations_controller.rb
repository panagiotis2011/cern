# encoding: utf-8
class Users::RegistrationsController < Devise::RegistrationsController
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
