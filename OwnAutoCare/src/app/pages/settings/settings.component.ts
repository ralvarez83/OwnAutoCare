import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';

import {
  IonContent,
  IonTitle,
  IonToolbar,
  IonHeader,
} from '@ionic/angular/standalone';
import { GoogleSignInComponent } from 'src/app/components/google-sign-in/google-sign-in.component';
import { AuthService } from 'src/app/services/auth.service';
import { GoogleSignOutComponent } from 'src/app/components/google-sign-out/google-sign-out.component';

@Component({
  selector: 'app-settings',
  templateUrl: './settings.component.html',
  styleUrls: ['./settings.component.scss'],
  imports: [
    CommonModule,
    IonContent,
    IonTitle,
    IonToolbar,
    IonHeader,
    GoogleSignInComponent,
    GoogleSignOutComponent,
  ],
})
export class SettingsComponent implements OnInit {
  constructor(private authService: AuthService) {}
  public isAuthenticated: boolean = false;

  ngOnInit() {
    this.authService.authState$.subscribe((isAuthenticated) => {
      this.isAuthenticated = isAuthenticated;
    });
  }
}
