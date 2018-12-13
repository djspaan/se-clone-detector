import { Injectable } from '@angular/core';
import {HttpClient} from '@angular/common/http';

import {Observable} from 'rxjs';
import {flatMap, map} from 'rxjs/operators';

import {Loc} from './loc';
import {CompilationUnit} from "./compilation-unit";
import {Duplication} from "./duplication";
import {zip} from "rxjs/internal/observable/zip";

@Injectable({
  providedIn: 'root'
})
export class DataService {
  compilationUnits: Observable<CompilationUnit[]>;
  duplications: Observable<any>;
  dataUnit: Observable<any>;

  private url = "http://localhost:8082/";
  private project = "project://smallsql0.21_src";

  constructor(private http: HttpClient) { this.init(); }

  init() {
    this.compilationUnits = this.http.get<any>(this.url + "classes?project=" + this.project).pipe(
      map(data => data.classes.map(c => new CompilationUnit(new Loc('', '', c.uri, 0, 0), c.srcUrl))),
      map(classes => {
        for (let c of classes) {
          this.http.get(c.srcUrl, {responseType: 'text'}).subscribe(src => c.content = src);
        }
        return classes;
      })
    );

    this.duplications = this.http.get<Duplication[]>(this.url + "clones?project=" + this.project).pipe(
      map(data => data.map(d => {
        let locs = d.locs.map(l => new Loc(l.fileUrl, l.fragmentUrl, l.uri, l.offset, l.length));
        return new Duplication(d.type, d.weight, locs);
      }))
    );

    this.dataUnit = zip(this.compilationUnits, this.duplications).pipe(
      map(([classes, duplications]) => {
        for (const cu of classes) {
          cu.duplications = duplications.filter(d => d.locs.filter(l => l.uri == cu.loc.uri).length > 0);
        }
        return classes;
      }),
      map(classes => {
        for (const cu of classes) {
          let duplicationsUris =  (<any>cu.duplications).map(d => d.locs.map(l => l.uri)).flat().filter(uri => uri != cu.loc.uri);
          duplicationsUris = duplicationsUris.filter((item, pos) => {return duplicationsUris.indexOf(item) == pos;});
          cu.clones = duplicationsUris.map(du => classes.find(c => c.loc.uri == du));
        }
        return classes;
      })
    );
  }

  byUri(uri: string): Observable<CompilationUnit> {
    return this.dataUnit.pipe(
      map( results => {
        return results.find(c => c.loc.uri === uri);
      })
    );
  }
}
