import { Component, OnInit } from '@angular/core';
import { Router, ActivatedRoute, ParamMap } from '@angular/router';

import {map, switchMap} from 'rxjs/operators';

import {DataService} from '../shared/data.service';
import {Observable} from 'rxjs';
import {CompilationUnit} from "../shared/compilation-unit";
import {Subject} from "rxjs/internal/Subject";

@Component({
  selector: 'app-detail',
  templateUrl: './detail.component.html',
  styleUrls: ['./detail.component.scss']
})
export class DetailComponent implements OnInit {
  class: CompilationUnit;
  dtTrigger: Subject<any> = new Subject();

  constructor(private route: ActivatedRoute, private router: Router, private dataService: DataService) { }

  ngOnInit() {
    this.route.paramMap.pipe(
      switchMap((params: ParamMap) => this.dataService.byUri(params.get('uri')))
    ).subscribe(c => {
      this.class = c;
      this.dtTrigger.next();
    });
  }

}
