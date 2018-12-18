import { Injectable } from '@angular/core';
import {HttpClient} from '@angular/common/http';

import {Observable} from 'rxjs';
import {map} from 'rxjs/operators';

import {Loc} from './loc';
import {CompilationUnit} from "./compilation-unit";
import {Duplication} from "./duplication";
import {zip} from "rxjs/internal/observable/zip";
import CONFIG from "../app.config";

@Injectable({
  providedIn: 'root'
})
export class DataService {
  dataUnit: Observable<CompilationUnit[]>;
  project = CONFIG.PROJECT;
  private url = "http://localhost:8082/";

  constructor(private http: HttpClient) { this.init(); }

  init() {
    let compilationUnits = this.getCompilationUnits();
    let duplications = this.getDuplications();

    this.dataUnit = this.zipClassesAndDuplications(compilationUnits, duplications);
  }

  zipClassesAndDuplications(compilationUnits: Observable<CompilationUnit[]>, duplications: Observable<Duplication[]>) {
    return zip(compilationUnits, duplications).pipe(
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
          cu.clones = duplicationsUris.map(du => classes.find(c => c.loc.uri == du)).filter(c => c != undefined);
        }
        return classes;
      })
    );
  }

  getCompilationUnits(): Observable<CompilationUnit[]> {
    return this.http.get<any>(this.url + "classes?project=" + this.project).pipe(
      map(data => data.classes.map((c,i) => new CompilationUnit('cu'+ i, new Loc('', '', c.uri, 0, 0), c.srcUrl))),
      map(classes => {
        for (let c of classes) {
          this.http.get(c.srcUrl, {responseType: 'text'}).subscribe(src => c.content = src);
        }
        return classes;
      })
    );
  }

  getDuplications(): Observable<Duplication[]> {
    return this.http.get<Duplication[]>(this.url + "clones?project=" + this.project).pipe(
      map(data => data.map((d,i) => {
        let locs = d.locs.map(l => new Loc(l.fileUrl, l.fragmentUrl, l.uri, l.offset, l.length));
        return new Duplication('d' + i, d.type, d.weight, locs);
      }))
    );
  }

  getProjects(): Observable<string[]> {
    return this.http.get<string[]>(this.url + 'projects').pipe(
      map((data: any) => Object.keys(data.projects))
    );
  }

  cuById(id: string): Observable<CompilationUnit> {
    return this.dataUnit.pipe(
      map( results => {
        return results.find(c => c.id === id);
      })
    );
  }

  duById(id: string): Observable<Duplication> {
    return this.getDuplications().pipe(
      map( results => {
        return results.find(d => d.id === id);
      })
    )
  }
}
