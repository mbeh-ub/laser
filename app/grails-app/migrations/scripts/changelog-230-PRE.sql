
/* change 'License Property: Open Access' and 'License Property: Archive' to 'License Property' */

/* execute after dbm, but BEFORE first start */

/*UPDATE property_definition SET pd_hard_data = true WHERE pd_description = 'License Property: Archive';*/
UPDATE property_definition SET pd_description = 'License Property' WHERE pd_description = 'License Property: Archive';
/*UPDATE property_definition SET pd_hard_data = false;*/

/*UPDATE property_definition SET pd_hard_data = true WHERE pd_description = 'License Property: Open Access';*/
UPDATE property_definition SET pd_description = 'License Property' WHERE pd_description = 'License Property: Open Access';
/*UPDATE property_definition SET pd_hard_data = false;*/