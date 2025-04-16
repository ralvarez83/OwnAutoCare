import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
import { User } from '../models/user.model';

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  private authState = new BehaviorSubject<boolean>(false);
  private user = new BehaviorSubject<User | null>(null);
  authState$ = this.authState.asObservable();
  user$ = this.user.asObservable();

  constructor() {}

  setAuthState(state: boolean, user: User) {
    this.authState.next(state);
    this.user.next(user);
  }

  logout() {
    this.authState.next(false);
    this.user.next(null);
    // Optionally, revoke the token
  }

  isAuthenticated(): boolean {
    return this.authState.value;
  }
  getUser(): User | null {
    return this.user.value;
  }
}
