import {Loc} from './loc';
import {Duplication} from "./duplication";

export class CompilationUnit {
  readonly loc: Loc;
  readonly srcUrl: string;
  content: string = '';
  duplications: Duplication[];
  clones: CompilationUnit[];
  duplicateLines: number = 0;

  constructor(loc: Loc, srcUrl: string) {
    this.loc = loc;
    this.srcUrl = srcUrl;
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


}
