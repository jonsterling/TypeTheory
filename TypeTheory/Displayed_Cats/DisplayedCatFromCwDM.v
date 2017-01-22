
(** * Displayed category from a category with display maps

Definition of the displayed category of display maps over a category [C]

Given a category with display maps [C], we define a displayed 
category over [C]. Objects over [c:C] are display maps into [c].

*)

Require Import UniMath.Foundations.Sets.
Require Import UniMath.CategoryTheory.precategories.
Require Import UniMath.CategoryTheory.UnicodeNotations.
Require Import UniMath.CategoryTheory.limits.pullbacks.

Require Import TypeTheory.Auxiliary.Auxiliary.
Require Import TypeTheory.Auxiliary.UnicodeNotations.

Require Import TypeTheory.Displayed_Cats.Auxiliary.
Require Import TypeTheory.Displayed_Cats.Core.
Require Import TypeTheory.Displayed_Cats.Fibrations.

Require Import TypeTheory.OtherDefs.DM.

Local Set Automatic Introduction.
(* only needed since imports globally unset it *)

(** ** Displayed category induced by a display map category

The total category associated to this displayed category is going to be isomorphic to
the subcategory of the arrow category where objects are display maps 
(instead of all morphisms) 

*)

(* TODO: we could define the concept of a full displayed subcategory 
   The predicate on objects here would be induced by the predicate [H : DM]
   on arrows of [C].
*)

Section DM_Disp.

Context (C:Precategory).

Section defining_the_displayed_cat.

Context (H : dm_sub_struct C).

Definition DM_disp_ob_mor : disp_precat_ob_mor C.
Proof.
  exists (fun x : C => DM_over H x).
  simpl; intros x y xx yy f. 
  unfold DM_over in *.
  exact (Σ ff : pr1 (pr1 xx) --> pr1 (pr1 yy), pr2 (pr1 xx) ;; f = ff ;; pr2 (pr1 yy)).
Defined.


Definition DM_disp_id_comp : disp_precat_id_comp _ DM_disp_ob_mor.
Proof.
  split.
  - simpl; intros.
    exists (identity _ ).
    abstract (
        etrans; [apply id_right |];
        apply pathsinv0, id_left ).
  - simpl; intros x y z f g xx yy zz ff gg.
    exists (pr1 ff ;; pr1 gg).
    abstract (
        etrans; [apply assoc |];
        etrans; [apply maponpaths_2, (pr2 ff) |];
        etrans; [eapply pathsinv0, assoc |];
        etrans; [apply maponpaths, (pr2 gg)|];
        apply assoc).
Defined.

Definition DM_disp_data : disp_precat_data _
  := (DM_disp_ob_mor ,, DM_disp_id_comp).

Lemma DM_disp_axioms : disp_precat_axioms C DM_disp_data.
Proof.
  repeat apply tpair; intros; try apply homset_property.
  - apply subtypeEquality.
    { intro. apply homset_property. }
    etrans. apply id_left.
    destruct ff as [ff H1]. 
    apply pathsinv0.
    etrans. refine (pr1_transportf (C⟦x,y⟧) _ _ _ _ _ _ ).
    use transportf_const.
  - apply subtypeEquality.
    { intro. apply homset_property. }
    etrans. apply id_right.
    destruct ff as [ff H1]. 
    apply pathsinv0.
    etrans. refine (pr1_transportf (C⟦x,y⟧) _ _ _ _ _ _ ).
    use transportf_const.
  - apply subtypeEquality.
    { intro. apply homset_property. }
    etrans. apply assoc.
    destruct ff as [ff H1]. 
    apply pathsinv0.
    etrans. unfold mor_disp.
    refine (pr1_transportf (C⟦x,w⟧) _ _ _ _ _ _ ).
    use transportf_const.
  - apply (isofhleveltotal2 2).
    + apply homset_property.
    + intro. apply isasetaprop. apply homset_property.
Qed.

Definition DM_disp : disp_precat C
  := (DM_disp_data ,, DM_disp_axioms).

End defining_the_displayed_cat.

Variable H : DM_structure C.

Local Definition D : disp_precat C := DM_disp H.

Lemma is_fibration_DM_disp : is_fibration D.
Proof.
  intros x y f d.
  unfold cartesian_lift.
  unfold D in d. cbn in d. unfold DM_over in d.
  destruct d as [[d g] H1].
  unfold is_cartesian.
  cbn in H1.
  use tpair. 
  - cbn. unfold DM_over.
    use tpair.
    + use tpair.
      * { use pb_ob_of_DM.
          - apply H.
          - exact d.
          - exact x.
          - exact (g,,H1).
          - exact y.
          - exact f.
        } 
      * cbn. 
        set (XR:= @pb_mor_of_DM C H _ _ (g,,H1) _ f). exact XR.
    + cbn.
      apply (pr2 (pr2 (pr1 H) _ _ _ _ _ )).
  - simpl.
    use tpair.
    + use tpair. 
      * use (@pb_mor_of_mor _ H).
      * abstract (cbn; apply pathsinv0; use (@sqr_comm_of_dm_sub_pb _ H) ).
    + cbn. 
      intros c'' g0 d'' hh.
      destruct d'' as [[e k] H2]. cbn in *.
      destruct hh as [h H3]. cbn in *.
      { use unique_exists.
        - use tpair.
          use PullbackArrow.
          + exact h.
          + exact (k ;; g0).
          + abstract (etrans; [apply (!H3) |]; apply assoc ) .
          + abstract (
                cbn;
                match goal with [|- _ = PullbackArrow ?PP _ _ _ _ ;; _    ] => 
                                set (P := PP) end;
                apply pathsinv0;
                apply (PullbackArrow_PullbackPr2 P)
              ).
        - cbn.
          apply subtypeEquality.
          { intro.  apply homset_property. }
          cbn.
          match goal with [|- PullbackArrow ?PP _ _ _ _  ;; _ = _ ] =>
                                set (P := PP) end.
          apply (PullbackArrow_PullbackPr1 P).
        - intro y0.
          simpl.
          admit.
        - cbn.
          intros y0 H5.
          apply subtypeEquality.
          { intro. apply homset_property. }
          destruct y0 as [p H6]. cbn in *.
          use PullbackArrowUnique.
          assert (H7 := maponpaths pr1 H5); cbn in H7.
          apply H7.
          apply (!H6).
Abort.

End DM_Disp.

