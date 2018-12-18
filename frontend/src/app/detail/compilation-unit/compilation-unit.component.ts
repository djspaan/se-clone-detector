import { Component, OnInit } from '@angular/core';
import {DataService} from "../../shared/data.service";
import {Subject} from "rxjs/internal/Subject";
import {ActivatedRoute, ParamMap, Router} from "@angular/router";
import {CompilationUnit} from "../../shared/compilation-unit";
import {switchMap} from "rxjs/operators";
import {HighlightJS, HighlightModule} from "ngx-highlightjs";

@Component({
  selector: 'app-compilation-unit',
  templateUrl: './compilation-unit.component.html',
  styles: [require('highlight.js/styles/github.css')],
  styleUrls: ['./compilation-unit.component.scss'],
  imports: [HighlightModule]
})
export class CompilationUnitComponent implements OnInit {
  class: CompilationUnit;
  dtTrigger: Subject<any> = new Subject();
  code: string;

  constructor(private route: ActivatedRoute, private router: Router, private dataService: DataService) { }

  ngOnInit() {
    this.route.paramMap.pipe(
      switchMap((params: ParamMap) => this.dataService.cuById(params.get('uri')))
    ).subscribe(c => {
      this.class = c;
      this.dtTrigger.next();
    });
  }

}
