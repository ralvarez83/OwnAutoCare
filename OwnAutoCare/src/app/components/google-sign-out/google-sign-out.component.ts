import { Component, OnInit } from '@angular/core';
import { IonIcon, IonButton } from '@ionic/angular/standalone';
import { AuthService } from 'src/app/services/auth.service';
import { environment } from 'src/environments/environment';

declare const google: any;

@Component({
  selector: 'app-google-sign-out',
  templateUrl: './google-sign-out.component.html',
  styleUrls: ['./google-sign-out.component.scss'],
  imports: [IonIcon, IonButton],
})
export class GoogleSignOutComponent implements OnInit {
  public userName: string = '';

  constructor(private authService: AuthService) {}

  ngOnInit() {
    this.authService.user$.subscribe((user) => {
      if (user) {
        this.userName = user.name;
      } else {
        this.userName = '';
      }
    });
  }

  logout() {
    google.accounts.id.disableAutoSelect();
    this.authService.logout();
  }
}
