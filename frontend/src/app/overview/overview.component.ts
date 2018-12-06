import { Component, OnInit } from '@angular/core';
import {DataService} from '../shared/data.service';
import {Class} from '../shared/class';
import {Observable} from 'rxjs';

@Component({
  selector: 'app-overview',
  templateUrl: './overview.component.html',
  styleUrls: ['./overview.component.scss']
})
export class OverviewComponent implements OnInit {
  private classes: Observable<Class[]>;

  constructor(private dataService: DataService) { }

  ngOnInit() {
    this.classes = this.dataService.all();
  }

}
