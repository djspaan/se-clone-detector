import { Injectable } from '@angular/core';
import {HttpClient} from '@angular/common/http';

import {Observable, of} from 'rxjs';
import {find, map, mergeMap} from 'rxjs/operators';

import {Class} from './class';
import {Clone} from './clone';
import {Loc} from './loc';

@Injectable({
  providedIn: 'root'
})
export class DataService {
  private classes: Observable<Class[]>;
  private clones: Observable<Clone[]>;

  private url = "http://localhost:8082/clones?project=";

  constructor(private http: HttpClient) { this.init(); }

  static getSeed(): Class[] {
    const classes = [];
    for (let i = 0; i < 100; i++) {
      classes.push(
        new Class(
          new Loc('exampleproject://ExampleClass' + i + '/...', 10, 5),
          'public class EmptyClass \n {}',
          [new Clone(
            1,
            new Loc('exampleproject://ExampleCloneClass/...', 10, 5)
          )],
          i,
          10.1
        )
      );
    }
    return classes;
  }

  init() {
    this.classes = of(DataService.getSeed());
    let data = this.http.get(this.url + "project://smallsql0.21_src").pipe(
        mergeMap(x => x.map(x => x.locs))
    ).subscribe(x => console.log(x));
  }

  allClasses(): Observable<Class[]> {
    return this.classes;
  }

  byUri(uri: string): Observable<Class> {
    return this.classes.pipe(
      map( results => results.find(c => c.getLoc().getUri() === uri))
    );
  }
}
