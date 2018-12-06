import {Clone} from './clone';
import {Loc} from './loc';

export class Class {
  private id = 1;
  readonly loc: Loc;
  private readonly content: string;
  private readonly clones: Clone[];
  private readonly duplicateLines: number;
  private readonly duplicatePercentage: number;

  constructor(loc: Loc, content: string, clones: Clone[], duplicateLines: number, duplicatePercentage: number) {
    this.loc = loc;
    this.content = content;
    this.clones = clones;
    this.duplicateLines = duplicateLines;
    this.duplicatePercentage = duplicatePercentage;
  }

  getLoc(): Loc {
    return this.loc;
  }

  getName(): string {
    return this.loc.getUri();
  }

  getContent(): string {
    return this.content;
  }

  getClones(): Clone[] {
    return this.clones;
  }

  getDuplicateLines(): number {
    return this.duplicateLines;
  }

  getDuplicatePercentage(): number {
    return this.duplicatePercentage;
  }
}
