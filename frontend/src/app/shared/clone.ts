import {Loc} from './loc';

export class Clone {
  private readonly type: number;
  private readonly loc: Loc;

  constructor(type: number, loc: Loc) {
    this.type = type;
    this.loc = loc;
  }

  getType(): number {
    return this.type;
  }

  getLoc(): Loc {
    return this.loc;
  }
}
