import {Loc} from './loc';

export class Duplication {
  type: number;
  weight: number;
  locs: Loc[];

  constructor(type: number, weight: number, locs: Loc[]) {
    this.type = type;
    this.weight = weight;
    this.locs = locs;
  }

  getUris(): string[] {
    return this.locs.map(l => l.uri);
  }
}
