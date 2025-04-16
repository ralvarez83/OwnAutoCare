import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class ConfigService {
  private config: any;

  constructor() {
    this.loadConfig();
  }

  async loadConfig(): Promise<any> {
    const response = await fetch('/assets/config.json');
    this.config = await response.json();
    return this.config;
  }

  getConfig(): any {
    return this.config;
  }
}
