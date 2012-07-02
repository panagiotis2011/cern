# encoding: utf-8
class ServicesController < ApplicationController
	before_filter :authenticate_user!, :except => [:create]


	def index
		# όλες οι υπηρεσίες αυθεντικοποίησης συνδέονται με τον φοιτητή που είναι συνδεδεμένος
		@services = current_user.services.all
	end


	def destroy
		# διαγραφή μιας υπηρεσίας αυθεντικοποίησης που είναι συνδεδεμένη με τον φοιτητή
		@service = current_user.services.find(params[:id])

		 if session[:service_id] == @service.id
      flash[:error] = 'You are currently signed in with this account!'
    else
		@service.destroy
		flash[:notice] = "Επιτυχής αποσύνδεση της υπηρεσίας από τον λογαριασμό σας."
		end
		redirect_to services_path
	end

	def create
		# αποθηκεύεται η μεταβλητή :service
		params[:provider] ? service_route = params[:provider] : service_route = 'non service (invalid callback)'
		# αποθηκεύεται όλη η πληροφορία που επιστρέφει από υπηρεσία κοινωνικής δικτύωσης στο omniauth
		omniauth = request.env["omniauth.auth"]
		# συνεχίζουμε μόνο αν υπάρχουν οι μεταβλητές omniauth και provider
		if omniauth and params[:provider]
			# για κάθε υπηρεσία δικτύωσης αποθηκεύουμε σε μεταβλητές όλη την πληροφορία
			if service_route == 'facebook'
				omniauth['info']['email'] ? email =  omniauth['info']['email'] : email = ''
				omniauth['info']['name'] ? name =  omniauth['info']['name'] : name = ''
				omniauth['uid'] ?  uid =  omniauth['uid'] : uid = ''
				omniauth['provider'] ? provider =  omniauth['provider'] : provider = ''
				omniauth['credentials']['token'] ? session['fb_access_token'] =  omniauth['credentials']['token'] : session['fb_access_token'] = ''
			elsif service_route == 'twitter'
				email = ''    # Το Twitter API ποτέ δεν επιστρέφει την διεύθυνση email
				omniauth['info']['name'] ? name =  omniauth['info']['name'] : name = ''
				omniauth['uid'] ?  uid =  omniauth['uid'] : uid = ''
				omniauth['provider'] ? provider =  omniauth['provider'] : provider = ''
			elsif service_route == 'google'
				omniauth['info']['email'] ? email =  omniauth['info']['email'] : email = ''
				omniauth['info']['name'] ? name =  omniauth['info']['name'] : name = ''
				omniauth['uid'] ? uid =  omniauth['uid'] : uid = ''
				omniauth['provider'] ? provider =  omniauth['provider'] : provider = ''
			else
				# εάν έχουμε μια υπηρεσία που δεν έχει αναγνωριστεί απλά αποθηκεύουμε την πληροφορία που έχει επιστραφεί
				render :text => omniauth.to_yaml
				#render :text => uid.to_s + " - " + name + " - " + email + " - " + provider
			return
		end
		# συνεχίζουμε μόνο αν υπάρχουν οι μεταβλητές uid και provider
		if uid != '' and provider != ''
			# κανείς δεν μπορεί να κάνει είσοδο δύο φορές ή να κάνει εγγραφή ενώ έχει κάνει ήδη σύνδεση
			if !user_signed_in?
				# ελέγχουμε αν ο φοιτητής έχει μπει στο σύστημα χρησιμοποιώντας τις υπηρεσίες δικτύωσης
				auth = Service.find_by_provider_and_uid(provider, uid)
				if auth
					flash[:notice] = 'Η σύνδεση μέσω ' + provider.capitalize + ' έγινε με επιτυχία .'
					sign_in_and_redirect(:user, auth.user)
				else
					# ελέγχουμε αν ο φοιτητής είναι ήδη εγεγγραμένος με αυτή την διεύθυνση email, αν δεν είναι οδηγείτε στην αρχική σελίδα
					if email != ''
						# αναζητούμε έναν φοιτητή με αυτή την διεύθυνση email
						existinguser = User.find_by_email(email)
						if existinguser
							# συνδέουμε την νέα υπηρεσία δικτύωσης με τον λογαριασμό του φοιτητή εάν είναι ίδια η διεύθυνση email
							existinguser.services.create(:provider => provider, :uid => uid, :uname => name, :uemail => email, :token => (session['fb_access_token'] rescue nil))
							flash[:notice] = 'Η σύνδεση με ' + provider.capitalize + ' έχει προστεθεί στον λογαριασμό σας ' + existinguser.email
							sign_in_and_redirect(:user, existinguser)
						else
							# δημιουργούμε έναν νέο φοιτητή κάνουμε εγγραφή και προσθέτουμε την υπηρεσία δικτύωσης
							name = name[0, 39] if name.length > 39             # otherwise our user validation will hit us
							# παίρνουμε το όνομα από την υπηρεσία δικτύωσης και θέτουμε email και τυχαίο κωδικό πρόσβασης
							user = User.new :email => email, :password => SecureRandom.hex(10), :fullname => name, :haslocalpw => false
							# προσθέτουμε την υπηρεσία δικτύωσης στον νέο φοιτητή
							user.services.build(:provider => provider, :uid => uid, :uname => name, :uemail => email, :token => (session['fb_access_token'] rescue nil))
							# δεν στέλνουμε email επιβεβαίωσης και απευθείας αποθηκεύουμε και επαληθεύουμε την νέα εγγραφή για τον φοιτητή
							user.skip_confirmation!
							user.save!
							user.confirm!
							# μήνυμα και είσοδος
							flash[:myinfo] = 'Ο λογαριασμός σας στον χώρο συζήτησης και ενημέρωσης έχει δημιουργηθεί μέσω' + provider.capitalize + '. Στο προφίλ σας μπορείτε να αλλάξετε τις προσωπικές σας πληροφορίες και να προσθέσετε κάποιον κωδικό ασφαλείας.'
							sign_in_and_redirect(:user, user)
						end
					else
						flash[:error] =  service_route.capitalize + ' δεν μπορεί να χρησιμοποιηθεί για την εγγραφή σας στον χώρο συζήτησης και ενημέρωσης μιας και δεν παρέχεται κάποιο έγκυρο email. Παρακαλώ χρησιμοποιήστε άλλο πάροχο αυθεντικοποίησης ή χρησιμοποιήστε το σύστημα πιστοποίσης της παρούσας σελίδας. Εάν έχετε ήδη κάποιο λογαριασμό κάνετε είσοδο και προσθέστε το ' + service_route.capitalize + ' στο προφίλ σας.'
						redirect_to new_user_session_path
					end
				end
			else
				# ο φοιτητής έχει κάνει ήδη είσοδο, ελέχουμε αν η υπηρεσία δικτύωσης είναι συνδεδεμένη με τον λογαριασμό του και αν όχι την προσθέτουμε
				auth = Service.find_by_provider_and_uid(provider, uid)
				if !auth
					current_user.services.create(:provider => provider, :uid => uid, :uname => name, :uemail => email, :token => (session['fb_access_token'] rescue nil))
					flash[:notice] = 'Η σύνδεση με ' + provider.capitalize + ' έχει προστεθεί στον λογαριασμό σας.'
					redirect_to services_path
				else
					flash[:notice] = service_route.capitalize + ' είναι ήδη συνδεδεμένη με τον λογαριασμό σας.'
					redirect_to services_path
				end
			end
		else
			flash[:error] =  service_route.capitalize + ' επιστρέφει λανθασμένα δεδομένα για το id του φοιτητή.'
			redirect_to new_user_session_path
		end
		else
			flash[:error] = 'Σφάλμα κατά την αυθεντικοποίηση μέσω ' + service_route.capitalize + '.'
			redirect_to new_user_session_path
		end
	end
end
