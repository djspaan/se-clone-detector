import {Loc} from './loc';
import {Duplication} from "./duplication";
import CONFIG from "../app.config";

export class CompilationUnit {
  readonly id: string;
  readonly loc: Loc;
  readonly srcUrl: string;
  content: string = '';
  duplications: Duplication[];
  clones: CompilationUnit[];
  duplicateLines: number = 0;

  constructor(id: string, loc: Loc, srcUrl: string) {
    this.id = id;
    this.loc = loc;
    this.srcUrl = srcUrl;
  }

  getName(): string {
    let splits = this.loc.uri.split('/');
    return splits[splits.length-1].replace('.java', '');
  }

  getFullName(): string {
    return this.loc.uri.replace(CONFIG.PROJECT, '');
  }

  getContentLines(): string[] {
    return this.content.split("\n");
  }

  getDuplicateLines(): number {
    let locs = (<any>this.duplications).map(d => d.locs.filter(l => l.uri == this.loc.uri)).flat();
    let lines = (<any>locs).map(l => this.content.substring(l.offset, l.offset + l.length)).map(str => str.split("\n")).flat();
    lines = lines.filter((item, pos) => lines.indexOf(item) == pos);
    this.duplicateLines = lines.length;
    return this.duplicateLines;
  }

  getDuplicatePercentage(): number {
    if (this.duplicateLines > 0 && this.getContentLines().length > 0) {
      return +(this.duplicateLines / this.getContentLines().length * 100).toFixed(2);
    }
    return 0;
  }

  getMarkedContent() : string {
    let mc = this.content;
    let locs = this.duplications.map(d => d.locs.filter(l => l.uri === this.loc.uri)).flat();
    locs.sort((a,b) => a.offset - b.offset);
    let count = 0;
    for (let l of locs) {
      mc = mc.substr(0, l.offset + count) + '<mark>' + mc.substr(l.offset + count); count += 6;
      mc = mc.substr(0, l.offset + l.length + count) + '</mark>' + mc.substr(l.offset + l.length + count); count += 7;
    }
    return mc;
  }

}
