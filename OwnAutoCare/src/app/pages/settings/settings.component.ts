import { Component, OnInit } from '@angular/core';
import {
  IonContent,
  IonTitle,
  IonToolbar,
  IonHeader,
} from '@ionic/angular/standalone';

@Component({
  selector: 'app-settings',
  templateUrl: './settings.component.html',
  styleUrls: ['./settings.component.scss'],
  imports: [IonContent, IonTitle, IonToolbar, IonHeader],
})
export class SettingsComponent implements OnInit {
  constructor() {}

  ngOnInit() {}
}
