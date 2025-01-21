import { Routes } from '@angular/router';
import { TabsPage } from './tabs.page';
import { NoVehiclesComponent } from '../../components/no-vehicles/no-vehicles.component';

import { VehicleDetailComponent } from '../../components/vehicle-detail/vehicle-detail.component';
import { SettingsComponent } from '../settings/settings.component';

export const routes: Routes = [
  {
    path: '',
    component: TabsPage,
    children: [
      {
        path: 'vehicle/:id',
        component: VehicleDetailComponent,
        pathMatch: 'full',
      },
      {
        path: 'settings',
        component: SettingsComponent,
      },
      {
        path: 'no-vehicles',
        component: NoVehiclesComponent,
      },
      // {
      //   path: 'tab1',
      //   loadChildren: () => import('../tab1/tab1.module').then(m => m.Tab1PageModule)
      // }
      // Agrega más rutas según sea necesario
    ],
  },
];
