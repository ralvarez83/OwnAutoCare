import { Routes } from '@angular/router';
import { TabsPage } from './tabs.page';
import { VehicleDetailComponent } from '../vehicle-detail/vehicle-detail.component';

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
      // {
      //   path: 'tab1',
      //   loadChildren: () => import('../tab1/tab1.module').then(m => m.Tab1PageModule)
      // }
      // Agrega más rutas según sea necesario
    ],
  },
];
