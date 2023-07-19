select   
  
'UPSERT' as [Action],  
  
t1.Movex_code as ProductId,  
  
t2.Ean13_Code as Gtin,  
  
t1.Rubis_Code as OpcoProductId,  
  
t2.ArticleFournisseur_Code as ManufacturerRefId,  
  
t2.DesignationLongue_Lbl as ProductTitle,  
  
t6.RaisonSociale_Lbl as ManufacturerName,  
  
t3.Marque_ID as ManufacturerReference,  
  
t3.Marque_Nom as BrandName,  
  
t4.Synonymes_Lbl as Keywords,  
  
t2.UniteVente_Code as OrderUnit,  
  
convert(int,t1.MinimunVente_Qte) as MinQuantity,  
  
convert(int,t1.MultipleVente_Nbr) as QuantitySteps,  
  
v1.Designation_longue as AdditionalInfo,  
  
t2.DesignationCourte_Lbl as ErpShortDescription,  
  
t2.Descriptif_Lbl as LongDescription,  
  
t8.Element_Code as Categories,  
  
t2.DelaiLivraison_Nbr as ExpectedDeliveryTime,  
  
t2.DureeGarantie_Nbr as Warranty,  
  
CASE   
  
       WHEN t5.Statut_Code IN('MANQUANT','SUPPRIME') THEN 'L'   
  
       ELSE 'A'   
  
END AS StockIndicator,  
  
t1.Classification_Num As Ranking,  
  
(select f1.CaractEtim_Code+char(31)+f4.CaractEtim_Lbl+char(31)+f1.CaractArticle_lbl+char(31)+isnull(f3.UniteEtim_Lbl,'')+char(31)+convert(varchar,ROW_NUMBER() over (order by f1.rubis_code, f1.Top5_Flg desc, f1.Ranking_Num ))+char(30)  
  
FROM Digital.OffreWebshop F2    
LEFT JOIN    Digital.CaracteristiqueArticle F1 on F1.Rubis_Code=F2.Rubis_code    
INNER JOIN  Digital.CaracteristiqueEtim F4 on F4.CaractEtim_Code=F1.CaractEtim_Code    
LEFT JOIN    Digital.UniteEtim F3 on F3.UniteEtim_Code=F1.UniteEtim_Code    
Where F2.Enseigne_Id = @Enseigne_Id and F2.rubis_code=t1.Rubis_code order by f1.Rubis_Code, f1.Top5_Flg desc, f1.Ranking_Num for xml path('')  
  
) as OneFieldFeature,  
  
(  
  
select   
  
p1.LongueurUc_Code+char(31)+p1.LargeurUc_Code+char(31)+p1.HauteurUc_Code+char(31)+p1.PoidsUc_Code+char(31)+p1.VolumeUc_Code+char(31)+  
  
convert(varchar,p1.UniteConditionnement_Qte)+char(31)+convert(varchar,p1.LongueurUc_Nbr)+char(31)+  
  
convert(varchar,p1.LargeurUc_Nbr)+char(31)+convert(varchar,p1.HauteurUc_Nbr)+char(31)+convert(varchar,p1.PoidsUc_Nbr)+char(31)+  
  
convert(varchar,p1.VolumeUc_Nbr)+char(31)+p1.Gtin14_Code+char(30)  
  
FROM         Logistique.ArticleConditionnement p1     
INNER JOIN   Digital.OffreWebshop p2 on p1.Rubis_Code=p2.Rubis_code    
WHERE p2.Enseigne_Id = @Enseigne_Id and p2.Rubis_code=t1.Rubis_code order by p1.rubis_code, p1.Niveau_Num for xml path ('')  
  
) as OneFieldPacking    
,  
  
(  
  
Select a3.Movex_Code+char(30)  
  
from Digital.RelationArticle a2      
inner join Digital.OffreWebshop a3 on a3.Rubis_Code =a2.AssocieRubis_Code and a2.Relation_Type='accessoires'  
  
where a2.Rubis_code=t1.Rubis_Code and a3.Enseigne_Id = @Enseigne_Id  order by a2.Rubis_code, a2.Ranking_Num for XML path ('')  
  
) as OneFieldAccesories    
,  
  
(  
  
select r1.Flag_Code +char(30) from   
  
(select fl1.rubis_code, fl1.flag_code from marketing.ArticleFlag fl1 where fl1.Rubis_code=t1.rubis_code and fl1.Actif_flg=1    
union  
  
select fl2.rubis_code, fl2.Type_Code from Produit.ArticleReglementaire fl2     
inner join Marketing.GestionFlag fl3 on fl2.Rubis_code=t1.rubis_code and fl3.Flag_Code=fl2.Type_Code ) r1    
for xml path ('')) as ProductListFlag    
,  
  
t10.movex_Code as ReplaceProductId,  
  
t12.Movex_Code as IsReplaceByProductId,  
  
t13.LongueurMinimumCoupe_Nbr as MinimumCutting,  
  
t2.Gamme_Nom As Series,  
  
v2.co2_total   As Co2Quantity,  
  
v2.green_class As GreenClass    
From         Digital.OffreWebshop t1     
INNER JOIN   Produit.Article t2 on t2.rubis_code=t1.Rubis_code    
INNER JOIN  Produit.ArticleSonepar t5 on t5.Rubis_Code=t2.Rubis_Code    
INNER JOIN  Marketing.Marque t3 on t3.Marque_ID=t2.Marque_ID    
INNER JOIN  Marketing.fournisseur t6 on t6.Fournisseur_ID=t3.Fournisseur_ID    
LEFT JOIN    (Marketing.FacetteGeneriqueRelation t7     
INNER JOIN  Marketing.FacetteGeneriquePyramide t8 on t8.FacetteGeneriquePyramide_ID=t7.FacetteGeneriquePyramideSource_ID and t8.Facette_ID='FC001') on t7.FacetteGeneriquePyramideCible_ID=t5.ClasseMarketing_ID    
LEFT JOIN    Digital.SynonymesArticle t4 on t4.Rubis_code=t1.Rubis_code    
LEFT JOIN    UPK_PIM.dbo.Designations v1 on v1.RubisCode= CAST(T1.Rubis_Code AS VARCHAR(32))  
  
LEFT JOIN  (Produit.Article t9 inner join produit.ArticleSonepar t10 on t10.Rubis_Code=t9.Rubis_Code) on t9.Marque_ID=t2.Marque_ID and t9.ArticleFournisseur_Code=t2.ArticleRemplace_Code    
LEFT JOIN  (Produit.Article t11 inner join produit.ArticleSonepar t12 on t12.Rubis_Code=t11.Rubis_Code) on t11.Marque_ID=t2.Marque_ID and t11.ArticleFournisseur_Code=t2.ArticleRemplacement_Code    
LEFT JOIN  Logistique.ArticleGeode t13 on t13.Rubis_code=t1.Rubis_code    
LEFT JOIN  UPK_PIM.[dbo].[UV_GREEN_OFFER_METRICS_SPARK] v2 on v2.product_id=t1.Rubis_code    
     
Where t1.Enseigne_Id = @Enseigne_Id and t8.ElementActif_Flg=1    