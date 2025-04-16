import { Component, OnInit, NgZone } from '@angular/core';
import { jwtDecode } from 'jwt-decode';
import { User } from 'src/app/models/user.model';
import { AuthService } from 'src/app/services/auth.service';
import { environment } from 'src/environments/environment';

declare const google: any;

@Component({
  selector: 'app-google-sign-in',
  templateUrl: './google-sign-in.component.html',
  styleUrls: ['./google-sign-in.component.css'],
})
export class GoogleSignInComponent implements OnInit {
  constructor(private ngZone: NgZone, private authService: AuthService) {}

  ngOnInit(): void {
    this.initializeGoogleSignIn();
  }

  initializeGoogleSignIn() {
    google.accounts.id.initialize({
      client_id: environment.clientId,
      callback: (response: any) => this.handleCredentialResponse(response),
    });

    google.accounts.id.renderButton(
      document.getElementById('google-signin-button'),
      { theme: 'outline', size: 'large' } // customization attributes
    );

    google.accounts.id.prompt(); // also display the One Tap dialog
  }

  handleCredentialResponse(response: any) {
    // response.credential is the JWT token
    console.log('Encoded JWT ID token: ' + response.credential);
    const token = response.credential;
    const decoded: any = jwtDecode(token);
    console.log(decoded);

    // Extract user information
    const user: User = {
      name: decoded.name,
      email: decoded.email,
      picture: decoded.picture,
      token: token,
    };
    //console.log(user);

    // You can decode the JWT token here or send it to your backend for verification
    // For demonstration, we'll just log it

    // If using NgZone, ensure any UI updates are run inside Angular's zone
    this.ngZone.run(() => {
      this.authService.setAuthState(true, user);
      // Update your application state here, e.g., store user info, navigate, etc.
    });
  }
}
