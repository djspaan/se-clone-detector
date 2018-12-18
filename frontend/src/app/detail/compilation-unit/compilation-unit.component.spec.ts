import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { CompilationUnitComponent } from './compilation-unit.component';

describe('CompilationUnitComponent', () => {
  let component: CompilationUnitComponent;
  let fixture: ComponentFixture<CompilationUnitComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ CompilationUnitComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(CompilationUnitComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
