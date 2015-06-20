(** * Systems.Auxiliary *)
(** Auxiliary background lemmas for the Ahrens/Lumsdaine/Voevodsky “Systems” project.  Possibly some should be upstreamed to “UniMath” eventually.
*)

Require Import UniMath.Foundations.Generalities.uu0.
Require Import UniMath.RezkCompletion.precategories.
Require Import Systems.UnicodeNotations.
Require Import UniMath.RezkCompletion.limits.pullbacks.

Lemma maponpaths_eq_idpath : ∀ (T1 T2 : UU) (f : T1 → T2) (t1 : T1) (e : t1 = t1)
          (H : e = idpath _ ), 
                                 maponpaths f e = idpath _ .
Proof.
  intros.
  rewrite H.
  apply idpath.
Defined.

Lemma idtoiso_concat_pr (C : precategory) (hs: has_homsets C) (a a' a'' : ob C)
  (p : a = a') (q : a' = a'') :
  idtoiso p ;; idtoiso q = idtoiso (p @ q).
Proof.
  apply pathsinv0.
  apply (base_paths _ _ (idtoiso_concat _ hs _ _ _ _ _ )).
Defined.

Lemma idtoiso_eq_idpath (C : precategory) (a : C) (e : a = a)
    (H : e = idpath _ )
  : identity a = idtoiso e.
Proof.
  rewrite H.
  apply idpath.
Qed.

Section on_pullbacks.

  Variable C : precategory.
  Variable hs : has_homsets C.
  Variables a b c d : C.
  Variables (f : a ⇒ b) (g : a ⇒ c) (k : b ⇒ d) (h : c ⇒ d).

(*
      f
   a----b
 g |    | k
   |    |
   c----d
     h 
    
*)

  Variable sqr_comm : f ;; k = g ;; h.
  Variable Pb : isPullback _ _ _ _ _ sqr_comm.

  Definition map_into_Pb {e : C} (x : e ⇒ b) (y : e ⇒ c)
      :  x ;; k = y ;; h → e ⇒ a
    := fun H => pr1 (pr1 (Pb _ x y H)).

  Definition Pb_map_commutes_1 {e : C} (x : e ⇒ b) (y : e ⇒ c) H
  : map_into_Pb x y H ;; f = x
    := (pr1 (pr2 (pr1 (Pb _ x y H)))).
  

  Definition Pb_map_commutes_2 {e : C} (x : e ⇒ b) (y : e ⇒ c) H
  : map_into_Pb x y H ;; g = y
    := (pr2 (pr2 (pr1 (Pb _ x y H)))).

  Lemma map_into_Pb_unique (e : C) (x y : e ⇒ a)
  : x ;; f = y ;; f → x ;; g = y ;; g → x = y.
  Proof.
    intros H H'.
    set (T:=@map_into_Pb _ (x ;; f)(y ;; g)).
    assert  (TH : x ;; f ;; k = y ;; g ;; h).
    { rewrite H. repeat rewrite <- assoc. rewrite sqr_comm. apply idpath. }
    pathvia (T TH).
    apply PullbackArrowUnique. apply idpath. assumption.
    apply pathsinv0. apply PullbackArrowUnique. apply pathsinv0; assumption.
    apply idpath.
  Qed.

  Lemma postcomp_pb_with_iso (y : C) (r : y ⇒ d) (i : iso b y) (Hi : i ;; r = k) :
    Σ H : f ;; i ;; r = g ;; h, isPullback _ _ _ _ _ H.
  Proof.
    refine (tpair _ _ _ ).
    eapply pathscomp0 ; [|apply sqr_comm].
    eapply pathscomp0. eapply pathsinv0; apply assoc.
    apply maponpaths. apply Hi.
    unfold isPullback.
    intros e s t HH.
    refine (tpair _ _ _ ).
    - refine (tpair _ _ _ ).
      set (T:= @map_into_Pb e).
      set (T':= T (s ;; inv_from_iso i) t).
      apply T'. { rewrite <- HH. rewrite <- assoc. apply maponpaths.
                  apply iso_inv_on_right. apply pathsinv0; assumption. }
                simpl.
      split.
      + assert (T1:= @Pb_map_commutes_1).
        eapply pathscomp0. apply assoc.
        rewrite T1.
        rewrite <- assoc.
        rewrite iso_after_iso_inv.
        apply id_right.
      + apply Pb_map_commutes_2.
    - intro t0.
      apply total2_paths_second_isaprop.
      apply isapropdirprod.
      + apply hs.
      + apply hs.
      + simpl.
        destruct t0 as [w [Ht1 Ht2]]; simpl in *.
        apply PullbackArrowUnique.
        * apply iso_inv_on_left.
          rewrite <- Ht1. apply assoc.
        * assumption.
Defined.    
 
End on_pullbacks.

Definition isaprop_Pullback (C : precategory) (H : is_category C)
           (a b c : C) (f : b ⇒ a) (g : c ⇒ a)
: isaprop (Pullback _  f g).
Proof.
  unfold Pullback.
  apply invproofirrelevance.
  unfold Pullback.
  intros Pb Pb'.
  apply total2_paths_isaprop.
  - intro; apply isofhleveltotal2.
    + destruct H as [H1 H2]. apply H2.
    + intros; apply isaprop_isPullback.
  - apply (total2_paths  (isotoid _ H (iso_from_Pullback_to_Pullback _  Pb Pb' ))). 
    rewrite transportf_dirprod, transportf_isotoid.
    rewrite inv_from_iso_iso_from_Pullback.
    rewrite transportf_isotoid.
    rewrite inv_from_iso_iso_from_Pullback.
    destruct Pb as [Cone bla];
    destruct Pb' as [Cone' bla'];
    simpl in *.
    destruct Cone as [p [h k]];
    destruct Cone' as [p' [h' k']];
    simpl in *. 
    unfold from_Pullback_to_Pullback;
    rewrite PullbackArrow_PullbackPr2, PullbackArrow_PullbackPr1.
    apply idpath.
Qed.

(*
Definition Pullback_type  {C : precategory}
           {a b c : C} (f : b ⇒ a) (g : c ⇒ a) : UU
 :=  (Σ  (p : C) (f' : p ⇒ b) (g' : p ⇒ c) (H0 : f' ;; f = g' ;; g),
      isPullback C f g f' g' H0).

Definition Pullback_weq_Pullback_type  (C : precategory)
           (a b c : C) (f : b ⇒ a) (g : c ⇒ a) :
  Pullback_type f g ≃ Pullback _ f g.
Proof.
  unfold Pullback_type, Pullback.
  eapply weqcomp. Focus 2. apply weqtotal2asstol.
  eapply weqcomp. Focus 2. eapply (weqbandf (idweq _ )). intro x. apply weqtotal2asstol.
  simpl.
  apply idweq.
Defined.

Definition isaprop_Pullback'  (C : precategory) (H : is_category C)
           (a b c : C) (f : b ⇒ a) (g : c ⇒ a) :
  isaprop (Pullback_type f g).
Proof.
  Search ( isofhlevel _  _  -> isofhlevel _  _ ).
  set (T:= isofhlevelweqb 1 (Pullback_weq_Pullback_type C a b c f g )).
  apply T. apply isaprop_Pullback. assumption.
Qed.
 *)

Arguments map_into_Pb {_ _ _ _ _} _ _ _ _ _ _ {_} _ _ _ .
Arguments Pb_map_commutes_1 {_ _ _ _ _} _ _ _ _ _ _ {_} _ _ _ .
Arguments Pb_map_commutes_2 {_ _ _ _ _} _ _ _ _ _ _ {_} _ _ _ .

(* (Surprised there’s no library function for this!) *)
Lemma transportf_pathscomp0 {A} {B} {a a' a'' : A} (e : a = a') (e' : a' = a'') (b : B a)
  : transportf B e' (transportf B e b) = transportf B (pathscomp0 e e') b.
Proof.
  destruct e; apply idpath.
Defined.

Lemma pathscomp0_assoc {A : UU} {a b c d : A}(e : a = b) (e' : b = c) (e'' : c = d) 
  : (e @ e') @ e'' = e @ (e' @ e'').
Proof.
  destruct e.
  apply idpath.
Defined.
  

Lemma transportf_comp_lemma (X : UU) (B : X -> UU) {A A' A'': X} (e : A = A'') (e' : A' = A'')
  (x : B A) (x' : B A')
  : transportf _ (e @ !e') x = x'
  -> transportf _ e x = transportf _ e' x'.
Proof.
  intro H.
  eapply pathscomp0. Focus 2.
    apply maponpaths. exact H.
  eapply pathscomp0. Focus 2.
    symmetry. apply transportf_pathscomp0.
  apply (maponpaths (fun p => transportf _ p x)).
  apply pathsinv0.
  eapply pathscomp0.
  - apply pathscomp0_assoc. 
  - eapply pathscomp0. 
    apply maponpaths.
    apply pathsinv0l.
    apply pathscomp0rid.
Qed.

Lemma transportf_comp_lemma_hset (X : UU) (B : X -> UU) (A : X) (e : A = A)
  {x x' : B A} (hs : isaset X)
  : x = x'
  -> transportf _ e x = x'.
Proof.
  intros ex.
  apply @pathscomp0 with (transportf _ (idpath _) x).
    apply (maponpaths (fun p => transportf _ p x)).
    apply hs.
  exact ex.
Qed.

Lemma transportf_ext (X : UU) (B : X -> UU) (A A' : X) (e e' : A = A') p :
  e = e' -> transportf _ e p = transportf B e' p.
Proof.
  intro H; induction H; apply idpath.
Defined.


Lemma cancel_postcomposition {C : precategory} {a b c : C} (f f' : a ⇒ b) (g : b ⇒ c)
: f = f' -> f ;; g = f' ;; g.
Proof.
  intro H. apply (maponpaths (fun f => f ;; g) H).
Defined.

Lemma idtoiso_postcompose_idtoiso_pre {C : precategory} {a b c : C} (g : a ⇒ b) (f : a ⇒ c)
              (p : b = c) :
  g = f ;; idtoiso (!p) -> g ;; idtoiso p = f.
Proof.
  induction p. simpl.
  rewrite id_right.
  induction 1.
  apply id_right.
Qed.

Tactic Notation "etrans" := eapply pathscomp0.
Tactic Notation "rew_trans_@" := repeat (etrans ; [ apply transportf_pathscomp0 |]).
Tactic Notation "sym" := apply pathsinv0.
Tactic Notation "assoc" := apply pathscomp0_assoc.
Tactic Notation "cancel_postcomposition" := apply cancel_postcomposition.