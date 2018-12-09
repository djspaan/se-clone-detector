import { Component, OnInit } from '@angular/core';
import { Router, ActivatedRoute, ParamMap } from '@angular/router';

import { switchMap } from 'rxjs/operators';

import {DataService} from '../shared/data.service';
import {Class} from '../shared/class';
import {Observable} from 'rxjs';

@Component({
  selector: 'app-detail',
  templateUrl: './detail.component.html',
  styleUrls: ['./detail.component.scss']
})
export class DetailComponent implements OnInit {
  class: Observable<Class>;

  constructor(private route: ActivatedRoute, private router: Router, private dataService: DataService) { }

  ngOnInit() {
    this.class = this.route.paramMap.pipe(
      switchMap((params: ParamMap) => this.dataService.byUri(params.get('uri')))
    );
  }

}
