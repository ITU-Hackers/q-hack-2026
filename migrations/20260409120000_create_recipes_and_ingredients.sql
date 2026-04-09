-- Create ingredients table
CREATE TABLE IF NOT EXISTS ingredients (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    emoji TEXT NOT NULL DEFAULT '',
    category TEXT NOT NULL DEFAULT 'other',
    default_unit TEXT NOT NULL DEFAULT '1 pc',
    default_price NUMERIC(6,2) NOT NULL DEFAULT 0.00
);

-- Create recipes table
CREATE TABLE IF NOT EXISTS recipes (
    id SERIAL PRIMARY KEY,
    region TEXT NOT NULL,
    dish TEXT NOT NULL UNIQUE,
    emoji TEXT NOT NULL DEFAULT ''
);

-- Create recipe_ingredients join table
CREATE TABLE IF NOT EXISTS recipe_ingredients (
    recipe_id INT NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    ingredient_id INT NOT NULL REFERENCES ingredients(id) ON DELETE CASCADE,
    PRIMARY KEY (recipe_id, ingredient_id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_recipes_region ON recipes(region);
CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_recipe ON recipe_ingredients(recipe_id);
CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_ingredient ON recipe_ingredients(ingredient_id);

-- Seed ingredients
INSERT INTO ingredients (name, emoji, category, default_unit, default_price) VALUES
    ('noodles', '🍜', 'grain', '400g', 1.49),
    ('pork_broth', '🍖', 'liquid', '1L', 2.49),
    ('soy_sauce', '🥫', 'condiment', '250ml', 1.99),
    ('garlic', '🧄', 'vegetable', '1 head', 0.49),
    ('ginger', '🫚', 'vegetable', '1 piece', 0.79),
    ('soft_boiled_egg', '🥚', 'protein', '4 pcs', 1.29),
    ('green_onion', '🧅', 'vegetable', '1 bunch', 0.89),
    ('nori', '🌿', 'other', '10 sheets', 2.49),
    ('sushi_rice', '🍚', 'grain', '500g', 2.29),
    ('salmon', '🐟', 'protein', '200g', 5.99),
    ('tuna', '🐟', 'protein', '200g', 5.49),
    ('avocado', '🥑', 'vegetable', '1 pc', 1.49),
    ('wasabi', '🟢', 'condiment', '30g', 1.99),
    ('pickled_ginger', '🫚', 'condiment', '100g', 1.49),
    ('chicken', '🍗', 'protein', '600g', 4.49),
    ('peanuts', '🥜', 'other', '100g', 1.49),
    ('dried_chiles', '🌶️', 'spice', '50g', 1.29),
    ('rice_vinegar', '🍶', 'condiment', '250ml', 1.79),
    ('sugar', '🍬', 'baking', '500g', 0.99),
    ('short_grain_rice', '🍚', 'grain', '500g', 2.29),
    ('beef', '🥩', 'protein', '500g', 5.99),
    ('spinach', '🌿', 'vegetable', '250g', 1.49),
    ('bean_sprouts', '🌱', 'vegetable', '200g', 0.99),
    ('carrot', '🥕', 'vegetable', '500g', 0.99),
    ('gochujang', '🌶️', 'condiment', '200g', 2.99),
    ('sesame_oil', '🫙', 'oil', '250ml', 2.49),
    ('egg', '🥚', 'protein', '6 pcs', 1.29),
    ('rice_noodles', '🍜', 'grain', '400g', 1.69),
    ('shrimp', '🦐', 'protein', '300g', 5.49),
    ('fish_sauce', '🐟', 'condiment', '250ml', 1.99),
    ('tamarind', '🟤', 'condiment', '200g', 1.79),
    ('lime', '🍋', 'fruit', '3 pcs', 0.99),
    ('pork', '🐷', 'protein', '500g', 4.49),
    ('dumpling_wrappers', '🥟', 'grain', '300g', 2.29),
    ('bamboo_shoots', '🎋', 'vegetable', '200g', 1.49),
    ('pear', '🍐', 'fruit', '2 pcs', 1.29),
    ('pork_shoulder', '🐷', 'protein', '800g', 6.99),
    ('hoisin_sauce', '🥫', 'condiment', '250ml', 2.29),
    ('honey', '🍯', 'condiment', '250g', 2.99),
    ('five_spice', '🌿', 'spice', '50g', 1.49),
    ('shaoxing_wine', '🍶', 'liquid', '250ml', 2.99),
    ('whole_duck', '🦆', 'protein', '1.8kg', 12.99),
    ('chinese_pancake', '🥞', 'grain', '10 pcs', 2.49),
    ('cucumber', '🥒', 'vegetable', '1 pc', 0.69),
    ('glass_noodles', '🍜', 'grain', '200g', 1.49),
    ('mushroom', '🍄', 'vegetable', '250g', 1.99),
    ('baguette', '🥖', 'grain', '1 pc', 1.29),
    ('pate', '🫙', 'protein', '100g', 2.49),
    ('pickled_daikon', '🥕', 'vegetable', '200g', 1.79),
    ('cilantro', '🌿', 'vegetable', '1 bunch', 0.79),
    ('jalapeño', '🌶️', 'vegetable', '3 pcs', 0.69),
    ('mayo', '🫙', 'condiment', '250ml', 1.49),
    ('soft_tofu', '🧊', 'protein', '400g', 1.99),
    ('ground_pork', '🐷', 'protein', '400g', 3.99),
    ('doubanjiang', '🌶️', 'condiment', '200g', 2.99),
    ('sichuan_pepper', '🌶️', 'spice', '50g', 1.99),
    ('broth', '🍖', 'liquid', '1L', 1.99),
    ('rice_cakes', '🍡', 'grain', '500g', 2.49),
    ('fish_cake', '🐟', 'protein', '200g', 2.29),
    ('onion', '🧅', 'vegetable', '3 pcs', 0.99),
    ('cooked_rice', '🍚', 'grain', '500g', 1.49),
    ('shallot', '🧅', 'vegetable', '3 pcs', 1.29),
    ('chili', '🌶️', 'spice', '3 pcs', 0.69),
    ('kecap_manis', '🥫', 'condiment', '250ml', 2.29),
    ('coconut_milk', '🥥', 'liquid', '400ml', 1.79),
    ('laksa_paste', '🌶️', 'condiment', '200g', 2.99),
    ('tofu_puffs', '🧊', 'protein', '200g', 1.99),
    ('sweet_potato', '🍠', 'vegetable', '500g', 1.49),
    ('flour', '🌾', 'baking', '1kg', 0.99),
    ('ice_water', '💧', 'liquid', '500ml', 0.00),
    ('dashi', '🍵', 'liquid', '500ml', 2.49),
    ('mirin', '🍶', 'condiment', '250ml', 2.49),
    ('miso_paste', '🫙', 'condiment', '300g', 2.99),
    ('tofu', '🧊', 'protein', '400g', 1.99),
    ('wakame', '🌿', 'other', '50g', 2.49),
    ('salt', '🧂', 'spice', '500g', 0.49),
    ('water', '💧', 'liquid', '1L', 0.00),
    ('beef_broth', '🍖', 'liquid', '1L', 2.49),
    ('beef_slices', '🥩', 'protein', '300g', 5.49),
    ('napa_cabbage', '🥬', 'vegetable', '1 head', 1.49),
    ('sesame_paste', '🫙', 'condiment', '200g', 2.49),
    ('lemongrass', '🌿', 'vegetable', '3 stalks', 1.29),
    ('galangal', '🫚', 'spice', '100g', 1.49),
    ('turmeric', '🟡', 'spice', '50g', 1.29),
    ('kaffir_lime', '🍋', 'fruit', '3 pcs', 1.49),
    ('rice_paper', '🧻', 'grain', '200g', 1.99),
    ('vermicelli', '🍜', 'grain', '200g', 1.29),
    ('lettuce', '🥬', 'vegetable', '1 head', 0.99),
    ('mint', '🌿', 'vegetable', '1 bunch', 0.89),
    ('peanut_sauce', '🥜', 'condiment', '200ml', 2.49),
    ('cabbage', '🥬', 'vegetable', '1 head', 1.29),
    ('pork_belly', '🐷', 'protein', '500g', 5.49),
    ('bonito_flakes', '🐟', 'other', '30g', 3.49),
    ('okonomiyaki_sauce', '🥫', 'condiment', '250ml', 2.49),
    ('octopus', '🐙', 'protein', '300g', 6.99),
    ('chicken_thighs', '🍗', 'protein', '600g', 4.49),
    ('sake', '🍶', 'liquid', '250ml', 3.99),
    ('sesame', '🫘', 'other', '100g', 1.29),
    ('tomato_puree', '🍅', 'condiment', '500ml', 1.29),
    ('cream', '🥛', 'dairy', '200ml', 1.19),
    ('butter', '🧈', 'dairy', '250g', 1.49),
    ('garam_masala', '🌶️', 'spice', '50g', 1.79),
    ('basmati_rice', '🍚', 'grain', '500g', 1.99),
    ('yogurt', '🥛', 'dairy', '500ml', 1.49),
    ('saffron', '🟡', 'spice', '1g', 4.99),
    ('ghee', '🧈', 'dairy', '200g', 3.49),
    ('fried_onions', '🧅', 'vegetable', '100g', 1.29),
    ('whole_spices', '🌿', 'spice', '50g', 2.49),
    ('yellow_lentils', '🫘', 'grain', '500g', 1.79),
    ('tomato', '🍅', 'vegetable', '500g', 1.29),
    ('cumin', '🌿', 'spice', '50g', 0.99),
    ('paneer', '🧀', 'dairy', '200g', 2.99),
    ('potato', '🥔', 'vegetable', '1kg', 1.49),
    ('green_peas', '🫛', 'vegetable', '300g', 1.29),
    ('coriander', '🌿', 'spice', '50g', 0.99),
    ('pastry_dough', '🥧', 'baking', '400g', 2.29),
    ('oil', '🫙', 'oil', '500ml', 1.99),
    ('tikka_spices', '🌶️', 'spice', '50g', 1.99),
    ('all_purpose_flour', '🌾', 'baking', '1kg', 0.99),
    ('yeast', '🫙', 'baking', '50g', 0.79),
    ('milk', '🥛', 'dairy', '1L', 1.09),
    ('chickpeas', '🫘', 'grain', '400g', 1.29),
    ('amchur', '🥭', 'spice', '50g', 1.49),
    ('cashews', '🥜', 'other', '100g', 2.49),
    ('cardamom', '🌿', 'spice', '25g', 2.99),
    ('cauliflower', '🥦', 'vegetable', '1 head', 1.79),
    ('lamb', '🐑', 'protein', '500g', 7.99),
    ('kashmiri_chili', '🌶️', 'spice', '50g', 1.79),
    ('rice', '🍚', 'grain', '1kg', 1.99),
    ('urad_dal', '🫘', 'grain', '500g', 1.99),
    ('fenugreek', '🌿', 'spice', '50g', 0.99),
    ('potato_filling', '🥔', 'vegetable', '300g', 1.49),
    ('mustard_seeds', '🟡', 'spice', '50g', 0.99),
    ('curry_leaves', '🌿', 'spice', '1 pack', 1.29),
    ('bhatura_dough', '🫓', 'baking', '400g', 2.29),
    ('mixed_vegetables', '🥕', 'vegetable', '500g', 2.29),
    ('pav_bun', '🍞', 'grain', '4 pcs', 1.29),
    ('pav_bhaji_masala', '🌶️', 'spice', '50g', 1.49),
    ('lemon', '🍋', 'fruit', '3 pcs', 0.99),
    ('mustard_greens', '🥬', 'vegetable', '250g', 1.79),
    ('spices', '🌶️', 'spice', '50g', 1.99),
    ('milk_powder', '🥛', 'dairy', '200g', 2.49),
    ('sugar_syrup', '🍯', 'condiment', '250ml', 1.99),
    ('rose_water', '🌹', 'condiment', '100ml', 1.99),
    ('whole_milk', '🥛', 'dairy', '1L', 1.29),
    ('pistachios', '🟢', 'other', '100g', 3.49),
    ('almonds', '🌰', 'other', '100g', 2.49),
    ('tandoori_masala', '🌶️', 'spice', '50g', 1.79),
    ('red_chili', '🌶️', 'spice', '50g', 0.99),
    ('vinegar', '🍶', 'condiment', '250ml', 1.29),
    ('pork_loin', '🐷', 'protein', '500g', 5.49),
    ('lentils', '🫘', 'grain', '500g', 1.79),
    ('pumpkin', '🎃', 'vegetable', '500g', 1.99),
    ('dhansak_masala', '🌶️', 'spice', '50g', 1.79),
    ('semolina_puri', '🫓', 'grain', '200g', 1.99),
    ('spiced_water', '💧', 'liquid', '500ml', 0.49),
    ('tamarind_chutney', '🟤', 'condiment', '200ml', 1.99),
    ('chaat_masala', '🌶️', 'spice', '50g', 1.29),
    ('okra', '🟢', 'vegetable', '250g', 1.99),
    ('jaggery', '🟤', 'baking', '200g', 1.49),
    ('pizza_dough', '🍕', 'baking', '400g', 1.79),
    ('tomato_sauce', '🍅', 'condiment', '400ml', 1.49),
    ('fresh_mozzarella', '🧀', 'dairy', '250g', 2.49),
    ('basil', '🌿', 'vegetable', '1 bunch', 1.29),
    ('olive_oil', '🫒', 'oil', '500ml', 3.99),
    ('spaghetti', '🍝', 'grain', '500g', 1.49),
    ('eggs', '🥚', 'protein', '6 pcs', 1.29),
    ('guanciale', '🥓', 'protein', '150g', 3.99),
    ('pecorino_romano', '🧀', 'dairy', '100g', 3.49),
    ('black_pepper', '🫙', 'spice', '50g', 1.29),
    ('parsley', '🌿', 'vegetable', '1 bunch', 0.79),
    ('arborio_rice', '🍚', 'grain', '500g', 2.49),
    ('white_wine', '🍷', 'liquid', '375ml', 3.99),
    ('parmesan', '🧀', 'dairy', '100g', 2.49),
    ('lasagna_sheets', '🍝', 'grain', '500g', 1.79),
    ('ground_beef', '🥩', 'protein', '500g', 4.49),
    ('bechamel', '🥛', 'condiment', '500ml', 1.99),
    ('mozzarella', '🧀', 'dairy', '250g', 2.29),
    ('mascarpone', '🧀', 'dairy', '250g', 2.99),
    ('espresso', '☕', 'liquid', '100ml', 2.49),
    ('savoiardi', '🍪', 'baking', '200g', 2.49),
    ('cocoa_powder', '🍫', 'baking', '100g', 1.99),
    ('marsala', '🍷', 'liquid', '250ml', 3.99),
    ('veal_shank', '🥩', 'protein', '500g', 8.99),
    ('celery', '🥬', 'vegetable', '1 head', 0.99),
    ('gremolata', '🌿', 'condiment', '50g', 1.49),
    ('sourdough_bread', '🍞', 'grain', '1 loaf', 2.99),
    ('ripe_tomato', '🍅', 'vegetable', '500g', 1.49),
    ('balsamic', '🍶', 'condiment', '250ml', 2.99),
    ('cannellini_beans', '🫘', 'grain', '400g', 1.49),
    ('pasta', '🍝', 'grain', '500g', 1.49),
    ('zucchini', '🥒', 'vegetable', '3 pcs', 1.49),
    ('gelatin', '🫙', 'baking', '10g', 1.29),
    ('vanilla', '🟡', 'baking', '1 pod', 2.99),
    ('mixed_berries', '🫐', 'fruit', '300g', 2.99),
    ('lemon_zest', '🍋', 'condiment', '10g', 0.49),
    ('veal', '🥩', 'protein', '500g', 8.99),
    ('prosciutto', '🥓', 'protein', '100g', 3.49),
    ('sage', '🌿', 'spice', '1 bunch', 1.29),
    ('peas', '🫛', 'vegetable', '300g', 1.29),
    ('breadcrumbs', '🍞', 'baking', '200g', 1.29),
    ('pasta_water', '💧', 'liquid', '250ml', 0.00),
    ('rosemary', '🌿', 'spice', '1 bunch', 1.29),
    ('sea_salt_flakes', '🧂', 'spice', '100g', 1.99),
    ('kale', '🥬', 'vegetable', '250g', 1.79),
    ('bread', '🍞', 'grain', '1 loaf', 1.99),
    ('t_bone_steak', '🥩', 'protein', '500g', 12.99),
    ('pine_nuts', '🌰', 'other', '50g', 3.49),
    ('ricotta', '🧀', 'dairy', '250g', 2.49),
    ('powdered_sugar', '🍬', 'baking', '200g', 0.99),
    ('chocolate_chips', '🍫', 'baking', '200g', 1.99),
    ('orange_zest', '🍊', 'condiment', '10g', 0.49),
    ('pastry_shells', '🥧', 'baking', '6 pcs', 2.99),
    ('eggplant', '🍆', 'vegetable', '2 pcs', 1.99),
    ('olives', '🫒', 'vegetable', '200g', 2.29),
    ('capers', '🫙', 'condiment', '100g', 1.99),
    ('stale_bread', '🍞', 'grain', '300g', 0.99),
    ('red_onion', '🧅', 'vegetable', '3 pcs', 1.29),
    ('red_wine_vinegar', '🍶', 'condiment', '250ml', 1.79),
    ('bucatini', '🍝', 'grain', '500g', 1.79),
    ('pecorino', '🧀', 'dairy', '100g', 3.49),
    ('chili_flakes', '🌶️', 'spice', '50g', 1.29),
    ('cavolo_nero', '🥬', 'vegetable', '250g', 1.99),
    ('egg_yolks', '🥚', 'protein', '6 pcs', 1.29),
    ('marsala_wine', '🍷', 'liquid', '250ml', 3.99),
    ('berries', '🫐', 'fruit', '300g', 2.99),
    ('corn_tortilla', '🌮', 'grain', '12 pcs', 1.99),
    ('pineapple', '🍍', 'fruit', '1 pc', 2.49),
    ('achiote', '🟠', 'spice', '50g', 1.79),
    ('salsa_verde', '🟢', 'condiment', '200ml', 1.99),
    ('white_onion', '🧅', 'vegetable', '3 pcs', 0.99),
    ('red_enchilada_sauce', '🌶️', 'condiment', '400ml', 2.49),
    ('oaxaca_cheese', '🧀', 'dairy', '200g', 3.49),
    ('sour_cream', '🥛', 'dairy', '200ml', 1.19),
    ('poblano_pepper', '🌶️', 'vegetable', '3 pcs', 1.49),
    ('hominy', '🌽', 'grain', '400g', 1.79),
    ('dried_guajillo', '🌶️', 'spice', '50g', 1.99),
    ('oregano', '🌿', 'spice', '25g', 0.99),
    ('radish', '🟢', 'vegetable', '1 bunch', 0.99),
    ('masa_harina', '🌽', 'grain', '500g', 1.99),
    ('red_chile_sauce', '🌶️', 'condiment', '400ml', 2.29),
    ('lard', '🐷', 'oil', '250g', 1.99),
    ('corn_husks', '🌽', 'other', '20 pcs', 1.49),
    ('flour_tortilla', '🌯', 'grain', '8 pcs', 1.99),
    ('salsa', '🍅', 'condiment', '200ml', 1.79),
    ('turkey', '🦃', 'protein', '1kg', 8.99),
    ('dark_chocolate', '🍫', 'baking', '100g', 2.49),
    ('white_fish', '🐟', 'protein', '400g', 5.99),
    ('lime_juice', '🍋', 'condiment', '100ml', 0.99),
    ('serrano', '🌶️', 'vegetable', '3 pcs', 0.69),
    ('cinnamon', '🟤', 'spice', '50g', 1.29),
    ('chocolate_sauce', '🍫', 'condiment', '200ml', 2.29),
    ('tortilla_strips', '🌮', 'grain', '100g', 1.49),
    ('habanero', '🌶️', 'vegetable', '3 pcs', 1.29),
    ('orange_juice', '🍊', 'liquid', '500ml', 1.99),
    ('bay_leaf', '🍃', 'spice', '10g', 0.99),
    ('black_beans', '🫘', 'grain', '400g', 1.29),
    ('queso_fresco', '🧀', 'dairy', '150g', 2.49),
    ('corn', '🌽', 'vegetable', '3 pcs', 1.49),
    ('cotija_cheese', '🧀', 'dairy', '100g', 2.99),
    ('chili_powder', '🌶️', 'spice', '50g', 1.29),
    ('shredded_chicken', '🍗', 'protein', '300g', 3.99),
    ('cotija', '🧀', 'dairy', '100g', 2.99),
    ('achiote_paste', '🟠', 'condiment', '100g', 1.99),
    ('banana_leaf', '🍃', 'other', '3 pcs', 1.49),
    ('masa', '🌽', 'grain', '500g', 1.99),
    ('refried_beans', '🫘', 'condiment', '400g', 1.49),
    ('chorizo', '🌭', 'protein', '200g', 2.99),
    ('beef_tripe', '🥩', 'protein', '500g', 3.99),
    ('watermelon', '🍉', 'fruit', '1 pc', 3.99),
    ('cucumber_drink', '🥒', 'vegetable', '1 pc', 0.69),
    ('lime_zest', '🍋', 'condiment', '10g', 0.49),
    ('raisins', '🟤', 'fruit', '100g', 1.29),
    ('ground_pork', '🐷', 'protein', '400g', 3.99),
    ('fruit_filling', '🍎', 'fruit', '300g', 2.49),
    ('walnut_cream', '🥜', 'condiment', '200ml', 2.99),
    ('pomegranate', '🔴', 'fruit', '1 pc', 2.49),
    ('tostada_shell', '🫓', 'grain', '8 pcs', 1.99),
    ('tasajo', '🥩', 'protein', '300g', 4.99),
    ('pumpkin_seeds', '🟢', 'other', '100g', 1.99),
    ('tomatillo', '🟢', 'vegetable', '300g', 1.79),
    ('epazote', '🌿', 'spice', '1 bunch', 1.29),
    ('red_wine_vinegar_condiment', '🍶', 'condiment', '250ml', 1.79),
    ('red_burgundy', '🍷', 'liquid', '375ml', 5.99),
    ('button_mushrooms', '🍄', 'vegetable', '250g', 1.99),
    ('lardons', '🥓', 'protein', '150g', 2.99),
    ('pearl_onions', '🧅', 'vegetable', '200g', 1.79),
    ('thyme', '🌿', 'spice', '1 bunch', 1.29),
    ('beef_chuck', '🥩', 'protein', '800g', 7.99),
    ('pinot_noir', '🍷', 'liquid', '375ml', 5.99),
    ('cremini_mushrooms', '🍄', 'vegetable', '250g', 2.29),
    ('red_bell_pepper', '🫑', 'vegetable', '2 pcs', 1.49),
    ('herbes_de_provence', '🌿', 'spice', '25g', 1.79),
    ('heavy_cream', '🥛', 'dairy', '200ml', 1.49),
    ('vanilla_bean', '🟡', 'baking', '1 pod', 3.99),
    ('caramel', '🍬', 'baking', '100ml', 1.99),
    ('shortcrust_pastry', '🥧', 'baking', '400g', 2.49),
    ('gruyere', '🧀', 'dairy', '200g', 3.99),
    ('nutmeg', '🟤', 'spice', '1 pc', 1.49),
    ('yellow_onion', '🧅', 'vegetable', '3 pcs', 0.99),
    ('beef_stock', '🍖', 'liquid', '1L', 2.49),
    ('emmental', '🧀', 'dairy', '200g', 3.49),
    ('cognac', '🥃', 'liquid', '100ml', 4.99),
    ('mixed_fish', '🐟', 'protein', '500g', 8.99),
    ('mussels', '🦪', 'protein', '500g', 4.99),
    ('fennel', '🌿', 'vegetable', '1 pc', 1.79),
    ('rouille', '🟠', 'condiment', '100ml', 2.49),
    ('duck_legs', '🦆', 'protein', '500g', 7.99),
    ('duck_fat', '🦆', 'oil', '200g', 4.99),
    ('golden_apples', '🍎', 'fruit', '4 pcs', 2.29),
    ('puff_pastry', '🥧', 'baking', '400g', 2.49),
    ('beef_brisket', '🥩', 'protein', '800g', 8.99),
    ('bone_marrow', '🦴', 'protein', '300g', 4.99),
    ('leek', '🥬', 'vegetable', '2 pcs', 1.49),
    ('turnip', '🟢', 'vegetable', '2 pcs', 1.29),
    ('bouquet_garni', '🌿', 'spice', '1 pack', 1.29),
    ('sole_fillet', '🐟', 'protein', '300g', 7.99),
    ('crêpe_batter', '🥞', 'baking', '500ml', 2.29),
    ('grand_marnier', '🍊', 'liquid', '100ml', 4.99),
    ('white_beans', '🫘', 'grain', '400g', 1.49),
    ('duck_confit', '🦆', 'protein', '400g', 8.99),
    ('pork_sausage', '🌭', 'protein', '400g', 3.49),
    ('tomato_paste', '🍅', 'condiment', '200g', 0.99),
    ('beef_tenderloin', '🥩', 'protein', '300g', 12.99),
    ('egg_yolk', '🥚', 'protein', '1 pc', 0.29),
    ('cornichon', '🥒', 'condiment', '100g', 1.79),
    ('dijon_mustard', '🟡', 'condiment', '200g', 1.99),
    ('worcestershire', '🥫', 'condiment', '200ml', 1.99),
    ('egg_whites', '🥚', 'protein', '6 pcs', 1.29),
    ('crème_anglaise', '🍮', 'dairy', '250ml', 2.49),
    ('almond', '🌰', 'other', '100g', 2.49),
    ('chicken_broth', '🍗', 'liquid', '1L', 2.49),
    ('chives', '🌿', 'vegetable', '1 bunch', 0.89),
    ('dark_chocolate_bar', '🍫', 'baking', '100g', 2.49),
    ('pastry_shell', '🥧', 'baking', '1 pc', 2.29),
    ('pastry_cream', '🍮', 'dairy', '250ml', 2.49),
    ('strawberry', '🍓', 'fruit', '300g', 2.99),
    ('apricot_glaze', '🟠', 'condiment', '100ml', 1.99),
    ('choux_pastry', '🥧', 'baking', '400g', 2.49),
    ('beef_roast', '🥩', 'protein', '1kg', 9.99),
    ('celery_root', '🥬', 'vegetable', '1 pc', 1.49),
    ('cloves', '🟤', 'spice', '25g', 1.29),
    ('gingersnap', '🍪', 'baking', '100g', 1.49),
    ('bread_flour', '🌾', 'baking', '1kg', 1.29),
    ('baking_soda', '🧂', 'baking', '100g', 0.79),
    ('coarse_salt', '🧂', 'spice', '200g', 1.29),
    ('beer', '🍺', 'liquid', '500ml', 1.49),
    ('mustard', '🟡', 'condiment', '200g', 1.49),
    ('sauerkraut', '🥬', 'vegetable', '400g', 1.79),
    ('bread_roll', '🍞', 'grain', '4 pcs', 1.29),
    ('caraway', '🌿', 'spice', '50g', 1.29),
    ('spätzle', '🍝', 'grain', '500g', 2.29),
    ('caramelized_onion', '🧅', 'vegetable', '200g', 1.79),
    ('bacon', '🥓', 'protein', '200g', 2.99),
    ('pickle', '🥒', 'condiment', '200g', 1.49),
    ('red_wine', '🍷', 'liquid', '375ml', 4.99),
    ('chocolate_sponge', '🍫', 'baking', '1 pc', 3.49),
    ('whipped_cream', '🥛', 'dairy', '250ml', 1.49),
    ('cherry', '🍒', 'fruit', '200g', 2.99),
    ('kirschwasser', '🍒', 'liquid', '100ml', 4.99),
    ('chocolate_shavings', '🍫', 'baking', '50g', 1.49),
    ('pasta_dough', '🍝', 'baking', '400g', 1.99),
    ('marjoram', '🌿', 'spice', '1 bunch', 0.99),
    ('thin_dough', '🍕', 'baking', '400g', 1.79),
    ('crème_fraîche', '🥛', 'dairy', '200ml', 1.79),
    ('pork_knuckle', '🍖', 'protein', '1kg', 6.99),
    ('apple', '🍎', 'fruit', '3 pcs', 1.49),
    ('juniper_berry', '🟣', 'spice', '25g', 1.99),
    ('strudel_dough', '🥧', 'baking', '400g', 2.29),
    ('vanilla_cream', '🍮', 'dairy', '250ml', 2.29),
    ('yeast_dough', '🍞', 'baking', '500g', 1.99),
    ('honey_almond_topping', '🍯', 'baking', '200g', 2.99),
    ('streusel_topping', '🍪', 'baking', '200g', 1.79),
    ('gingerbread', '🍪', 'baking', '100g', 1.79),
    ('ground_veal', '🥩', 'protein', '500g', 6.99),
    ('anchovy', '🐟', 'protein', '50g', 1.99),
    ('cream_sauce', '🥛', 'condiment', '250ml', 1.99),
    ('corned_beef', '🥩', 'protein', '400g', 3.99),
    ('beetroot', '🔴', 'vegetable', '300g', 1.49),
    ('pickled_herring', '🐟', 'protein', '200g', 2.99),
    ('peppercorn', '🫙', 'spice', '50g', 1.49),
    ('roasted_peanuts', '🥜', 'other', '100g', 1.69),
    ('tamarind_paste', '🟤', 'condiment', '200g', 1.99),
    ('green_curry_paste', '🟢', 'condiment', '200g', 2.49),
    ('thai_basil', '🌿', 'vegetable', '1 bunch', 1.29),
    ('lime_leaves', '🍃', 'spice', '10g', 1.29),
    ('kaffir_lime_leaves', '🍃', 'spice', '10g', 1.29),
    ('straw_mushrooms', '🍄', 'vegetable', '200g', 2.29),
    ('bird_eye_chili', '🌶️', 'vegetable', '50g', 0.99),
    ('green_papaya', '🟢', 'vegetable', '1 pc', 2.49),
    ('dried_shrimp', '🦐', 'protein', '50g', 2.49),
    ('palm_sugar', '🟤', 'baking', '200g', 1.49),
    ('massaman_paste', '🌶️', 'condiment', '200g', 2.99),
    ('pearl_onion', '🧅', 'vegetable', '200g', 1.79),
    ('jasmine_rice', '🍚', 'grain', '500g', 1.99),
    ('spring_onion', '🧅', 'vegetable', '1 bunch', 0.89),
    ('white_pepper', '🫙', 'spice', '50g', 1.29),
    ('wide_rice_noodles', '🍜', 'grain', '400g', 1.89),
    ('chinese_broccoli', '🥦', 'vegetable', '250g', 1.79),
    ('dark_soy_sauce', '🥫', 'condiment', '250ml', 2.29),
    ('oyster_sauce', '🦪', 'condiment', '250ml', 1.99),
    ('glutinous_rice', '🍚', 'grain', '500g', 2.29),
    ('ripe_mango', '🥭', 'fruit', '2 pcs', 2.99),
    ('pandan_leaf', '🌿', 'spice', '5 pcs', 1.29),
    ('oyster_mushroom', '🍄', 'vegetable', '200g', 2.49),
    ('holy_basil', '🌿', 'vegetable', '1 bunch', 1.49),
    ('red_curry_paste', '🔴', 'condiment', '200g', 2.49),
    ('khao_soi_paste', '🌶️', 'condiment', '200g', 2.99),
    ('pickled_mustard', '🟡', 'condiment', '200g', 1.79),
    ('crispy_noodles', '🍜', 'grain', '100g', 1.49),
    ('coriander_root', '🌿', 'spice', '50g', 1.29),
    ('egg_noodles', '🍜', 'grain', '400g', 1.69),
    ('oyster', '🦪', 'protein', '300g', 7.99),
    ('rice_flour', '🌾', 'baking', '500g', 1.49),
    ('tapioca_flour', '🌾', 'baking', '500g', 1.49),
    ('sriracha', '🌶️', 'condiment', '250ml', 2.29),
    ('pandan', '🌿', 'spice', '5 pcs', 1.29),
    ('corn_kernels', '🌽', 'vegetable', '200g', 1.29),
    ('grilled_pork', '🐷', 'protein', '300g', 4.49),
    ('toasted_rice_powder', '🍚', 'spice', '50g', 1.29),
    ('white_turmeric', '🟡', 'spice', '50g', 1.79),
    ('vegetables', '🥕', 'vegetable', '500g', 2.29),
    ('shrimp_paste', '🦐', 'condiment', '50g', 1.99),
    ('fish', '🐟', 'protein', '400g', 5.49),
    ('green_bean', '🟢', 'vegetable', '200g', 1.49),
    ('sweet_chili_sauce', '🌶️', 'condiment', '250ml', 1.99),
    ('glutinous_rice_flour', '🌾', 'baking', '500g', 1.49),
    ('taro', '🟤', 'vegetable', '300g', 1.99),
    ('ground_lamb', '🐑', 'protein', '500g', 6.99),
    ('tahini', '🫙', 'condiment', '200g', 2.99),
    ('paprika', '🔴', 'spice', '50g', 1.29),
    ('dried_chickpeas', '🫘', 'grain', '500g', 1.79),
    ('fresh_parsley', '🌿', 'vegetable', '1 bunch', 0.79),
    ('fine_bulgur', '🌾', 'grain', '500g', 1.79),
    ('flat_leaf_parsley', '🌿', 'vegetable', '1 bunch', 0.79),
    ('bomba_rice', '🍚', 'grain', '500g', 3.49),
    ('prawn', '🦐', 'protein', '300g', 6.99),
    ('mussel', '🦪', 'protein', '500g', 4.49),
    ('smoked_paprika', '🔴', 'spice', '50g', 1.79),
    ('garlic_sauce', '🧄', 'condiment', '200ml', 1.99),
    ('pita', '🫓', 'grain', '4 pcs', 1.49),
    ('sumac', '🔴', 'spice', '50g', 1.79),
    ('feta', '🧀', 'dairy', '200g', 2.49),
    ('phyllo_dough', '🥧', 'baking', '400g', 2.49),
    ('dill', '🌿', 'spice', '1 bunch', 0.89),
    ('greek_yogurt', '🥛', 'dairy', '200g', 1.29),
    ('fresh_dill', '🌿', 'spice', '1 bunch', 0.89),
    ('walnuts', '🥜', 'other', '100g', 2.49),
    ('dried_oregano', '🌿', 'spice', '25g', 0.99),
    ('tzatziki', '🥒', 'condiment', '200ml', 1.99),
    ('bulgur', '🌾', 'grain', '500g', 1.79),
    ('allspice', '🟤', 'spice', '50g', 1.49),
    ('red_bell_pepper_vegetable', '🫑', 'vegetable', '2 pcs', 1.49),
    ('romaine', '🥬', 'vegetable', '1 head', 1.29),
    ('pita_chips', '🫓', 'grain', '200g', 1.99),
    ('grape_leaves', '🍃', 'other', '30 pcs', 2.49),
    ('strained_yogurt', '🥛', 'dairy', '200g', 1.49),
    ('zaatar', '🌿', 'spice', '50g', 1.99),
    ('fresh_mint', '🌿', 'vegetable', '1 bunch', 0.89),
    ('semolina', '🌾', 'grain', '500g', 1.49),
    ('merguez', '🌭', 'protein', '300g', 3.99),
    ('root_vegetables', '🥕', 'vegetable', '500g', 2.29),
    ('harissa', '🌶️', 'condiment', '200g', 2.49),
    ('ras_el_hanout', '🌿', 'spice', '50g', 2.49),
    ('bread_dough', '🍞', 'baking', '400g', 1.79),
    ('nigella_seeds', '⚫', 'spice', '50g', 1.29),
    ('lamb_shoulder', '🐑', 'protein', '800g', 9.99),
    ('sherry_vinegar', '🍶', 'condiment', '250ml', 2.99),
    ('walnut', '🥜', 'other', '100g', 2.49),
    ('black_olives', '🫒', 'vegetable', '200g', 2.29),
    ('dijon_vinaigrette', '🟡', 'condiment', '200ml', 2.29),
    ('cherry_tomato', '🍅', 'vegetable', '250g', 1.79),
    ('black_pudding', '🟤', 'protein', '200g', 2.99),
    ('oatmeal', '🌾', 'grain', '500g', 1.29),
    ('smoked_pork', '🐷', 'protein', '300g', 4.49),
    ('pinkel_sausage', '🌭', 'protein', '300g', 3.49),
    ('apple_sauce', '🍎', 'condiment', '200ml', 1.29),
    ('clarified_butter', '🧈', 'dairy', '200g', 3.49),
    ('pepper', '🫙', 'spice', '50g', 1.29),
    ('yellow_squash', '🟡', 'vegetable', '2 pcs', 1.49),
    ('red_pepper', '🫑', 'vegetable', '2 pcs', 1.49),
    ('black_pepper_spice', '🫙', 'spice', '50g', 1.29),
    ('sugar_glaze', '🍬', 'baking', '100ml', 1.29),
    ('candied_peel', '🍊', 'baking', '100g', 1.99),
    ('bone_broth', '🍖', 'liquid', '1L', 2.49),
    ('carrots', '🥕', 'vegetable', '500g', 0.99),
    ('cashew', '🥜', 'other', '100g', 2.49),
    ('coconut_chutney', '🥥', 'condiment', '200ml', 1.99),
    ('dry_white_wine', '🍷', 'liquid', '375ml', 3.99),
    ('green_beans', '🟢', 'vegetable', '200g', 1.49),
    ('pea_eggplant', '🟢', 'vegetable', '200g', 2.49),
    ('ranchero_sauce', '🌶️', 'condiment', '400ml', 2.29),
    ('risotto_rice', '🍚', 'grain', '500g', 2.49),
    ('sambar', '🍛', 'condiment', '200ml', 1.99),
    ('star_anise', '⭐', 'spice', '25g', 1.49),
    ('tortilla', '🌮', 'grain', '8 pcs', 1.99)
ON CONFLICT (name) DO NOTHING;

-- Seed recipes
INSERT INTO recipes (region, dish, emoji) VALUES
    ('Asian', 'Ramen', '🍜'),
    ('Asian', 'Sushi', '🍣'),
    ('Asian', 'Kung_Pao_Chicken', '🐔'),
    ('Asian', 'Bibimbap', '🍚'),
    ('Asian', 'Pad_Thai', '🍜'),
    ('Asian', 'Dim_Sum', '🥟'),
    ('Asian', 'Bulgogi', '🥩'),
    ('Asian', 'Pho', '🍜'),
    ('Asian', 'Gyoza', '🥟'),
    ('Asian', 'Char_Siu', '🐷'),
    ('Asian', 'Peking_Duck', '🦆'),
    ('Asian', 'Japchae', '🍝'),
    ('Asian', 'Banh_Mi', '🥖'),
    ('Asian', 'Mapo_Tofu', '🌶️'),
    ('Asian', 'Tteokbokki', '🔴'),
    ('Asian', 'Nasi_Goreng', '🍛'),
    ('Asian', 'Laksa', '🍜'),
    ('Asian', 'Tempura', '🍤'),
    ('Asian', 'Miso_Soup', '🥣'),
    ('Asian', 'Hot_Pot', '🫕'),
    ('Asian', 'Rendang', '🍛'),
    ('Asian', 'Spring_Rolls', '🌯'),
    ('Asian', 'Okonomiyaki', '🥞'),
    ('Asian', 'Takoyaki', '🐙'),
    ('Asian', 'Yakitori', '🍢'),
    ('Indian', 'Butter_Chicken', '🍛'),
    ('Indian', 'Biryani', '🍚'),
    ('Indian', 'Dal_Tadka', '🫘'),
    ('Indian', 'Palak_Paneer', '🌿'),
    ('Indian', 'Samosa', '🔺'),
    ('Indian', 'Chicken_Tikka_Masala', '🍗'),
    ('Indian', 'Naan', '🫓'),
    ('Indian', 'Chana_Masala', '🫘'),
    ('Indian', 'Korma', '🍛'),
    ('Indian', 'Aloo_Gobi', '🥔'),
    ('Indian', 'Rogan_Josh', '🐑'),
    ('Indian', 'Dosa', '🥞'),
    ('Indian', 'Idli', '⚪'),
    ('Indian', 'Chole_Bhature', '🫘'),
    ('Indian', 'Pav_Bhaji', '🍔'),
    ('Indian', 'Saag_Paneer', '🌿'),
    ('Indian', 'Gulab_Jamun', '🟤'),
    ('Indian', 'Kheer', '🍮'),
    ('Indian', 'Tandoori_Chicken', '🍗'),
    ('Indian', 'Vindaloo', '🌶️'),
    ('Indian', 'Malai_Kofta', '🧆'),
    ('Indian', 'Dhansak', '🍛'),
    ('Indian', 'Pani_Puri', '💧'),
    ('Indian', 'Bhindi_Masala', '🟢'),
    ('Indian', 'Mishti_Doi', '🍮'),
    ('Italian', 'Pizza_Margherita', '🍕'),
    ('Italian', 'Pasta_Carbonara', '🍝'),
    ('Italian', 'Risotto_Milanese', '🍚'),
    ('Italian', 'Lasagna', '🧀'),
    ('Italian', 'Tiramisu', '🍰'),
    ('Italian', 'Osso_Buco', '🍖'),
    ('Italian', 'Bruschetta', '🥖'),
    ('Italian', 'Minestrone', '🥣'),
    ('Italian', 'Gnocchi', '🥔'),
    ('Italian', 'Panna_Cotta', '🍮'),
    ('Italian', 'Saltimbocca', '🥩'),
    ('Italian', 'Arancini', '🍙'),
    ('Italian', 'Cacio_e_Pepe', '🍝'),
    ('Italian', 'Focaccia', '🍞'),
    ('Italian', 'Ribollita', '🥣'),
    ('Italian', 'Bistecca_Fiorentina', '🥩'),
    ('Italian', 'Pesto_Pasta', '🍝'),
    ('Italian', 'Frittata', '🍳'),
    ('Italian', 'Cannoli', '🧁'),
    ('Italian', 'Caponata', '🍆'),
    ('Italian', 'Supplì', '🍙'),
    ('Italian', 'Amatriciana', '🍝'),
    ('Italian', 'Panzanella', '🥗'),
    ('Italian', 'Ribollita_Toscana', '🥣'),
    ('Italian', 'Zabaglione', '🍮'),
    ('Mexican', 'Tacos_al_Pastor', '🌮'),
    ('Mexican', 'Guacamole', '🥑'),
    ('Mexican', 'Enchiladas', '🌯'),
    ('Mexican', 'Chiles_Rellenos', '🌶️'),
    ('Mexican', 'Pozole_Rojo', '🍲'),
    ('Mexican', 'Tamales', '🫔'),
    ('Mexican', 'Quesadillas', '🧀'),
    ('Mexican', 'Mole_Negro', '🍫'),
    ('Mexican', 'Ceviche', '🐟'),
    ('Mexican', 'Churros', '🍩'),
    ('Mexican', 'Sopa_de_Lima', '🍋'),
    ('Mexican', 'Huevos_Rancheros', '🍳'),
    ('Mexican', 'Carnitas', '🐷'),
    ('Mexican', 'Elote', '🌽'),
    ('Mexican', 'Birria', '🍖'),
    ('Mexican', 'Flautas', '🌯'),
    ('Mexican', 'Cochinita_Pibil', '🐷'),
    ('Mexican', 'Sopes', '🫓'),
    ('Mexican', 'Menudo', '🍲'),
    ('Mexican', 'Tostadas', '🫓'),
    ('Mexican', 'Agua_Fresca', '🍉'),
    ('Mexican', 'Arroz_con_Leche', '🍚'),
    ('Mexican', 'Chiles_en_Nogada', '🇲🇽'),
    ('Mexican', 'Tlayuda', '🫓'),
    ('Mexican', 'Pepián_Verde', '🟢'),
    ('French', 'Croissant', '🥐'),
    ('French', 'Coq_au_Vin', '🍗'),
    ('French', 'Boeuf_Bourguignon', '🥩'),
    ('French', 'Ratatouille', '🍆'),
    ('French', 'Crème_Brûlée', '🍮'),
    ('French', 'Quiche_Lorraine', '🥧'),
    ('French', 'French_Onion_Soup', '🧅'),
    ('French', 'Bouillabaisse', '🐟'),
    ('French', 'Duck_Confit', '🦆'),
    ('French', 'Tarte_Tatin', '🍎'),
    ('French', 'Soupe_à_l''Oignon', '🧅'),
    ('French', 'Blanquette_de_Veau', '🥩'),
    ('French', 'Salade_Niçoise', '🥗'),
    ('French', 'Pot-au-Feu', '🍲'),
    ('French', 'Sole_Meunière', '🐟'),
    ('French', 'Gratin_Dauphinois', '🥔'),
    ('French', 'Crêpes_Suzette', '🥞'),
    ('French', 'Cassoulet', '🍲'),
    ('French', 'Steak_Tartare', '🥩'),
    ('French', 'Île_Flottante', '🍮'),
    ('French', 'Vichyssoise', '🥣'),
    ('French', 'Mousse_au_Chocolat', '🍫'),
    ('French', 'Confit_Byaldi', '🍆'),
    ('French', 'Tarte_aux_Fraises', '🍓'),
    ('French', 'Gougères', '🧀'),
    ('German', 'Sauerbraten', '🥩'),
    ('German', 'Schnitzel', '🥩'),
    ('German', 'Bratwurst', '🌭'),
    ('German', 'Pretzels', '🥨'),
    ('German', 'Käsespätzle', '🧀'),
    ('German', 'Sauerkraut', '🥬'),
    ('German', 'Rouladen', '🥩'),
    ('German', 'Kartoffelsalat', '🥔'),
    ('German', 'Schwarzwälder_Kirschtorte', '🍰'),
    ('German', 'Lebkuchen', '🍪'),
    ('German', 'Maultaschen', '🥟'),
    ('German', 'Flammkuchen', '🍕'),
    ('German', 'Zwiebelkuchen', '🧅'),
    ('German', 'Reibekuchen', '🥔'),
    ('German', 'Grünkohl', '🥬'),
    ('German', 'Eisbein', '🍖'),
    ('German', 'Himmel_und_Erde', '🍎'),
    ('German', 'Linsensuppe', '🥣'),
    ('German', 'Apfelstrudel', '🍎'),
    ('German', 'Bienenstich', '🍰'),
    ('German', 'Pfefferpotthast', '🥩'),
    ('German', 'Königsberger_Klopse', '🧆'),
    ('German', 'Labskaus', '🥔'),
    ('German', 'Streuselkuchen', '🍰'),
    ('German', 'Rollmops', '🐟'),
    ('Thai', 'Pad_Thai', '🍜'),
    ('Thai', 'Green_Curry', '🍛'),
    ('Thai', 'Tom_Yum_Goong', '🍲'),
    ('Thai', 'Som_Tum', '🥗'),
    ('Thai', 'Massaman_Curry', '🍛'),
    ('Thai', 'Khao_Pad', '🍳'),
    ('Thai', 'Larb_Moo', '🥬'),
    ('Thai', 'Pad_See_Ew', '🍝'),
    ('Thai', 'Mango_Sticky_Rice', '🥭'),
    ('Thai', 'Tom_Kha_Gai', '🥥'),
    ('Thai', 'Pad_Krapow_Moo', '🌿'),
    ('Thai', 'Gaeng_Daeng', '🍛'),
    ('Thai', 'Khao_Soi', '🍜'),
    ('Thai', 'Satay', '🍢'),
    ('Thai', 'Pad_Woon_Sen', '🍜'),
    ('Thai', 'Gai_Yang', '🍗'),
    ('Thai', 'Yam_Woon_Sen', '🍜'),
    ('Thai', 'Gaeng_Keow_Wan', '🍛'),
    ('Thai', 'Hoy_Tod', '🦪'),
    ('Thai', 'Khanom_Krok', '🥥'),
    ('Thai', 'Nam_Tok_Moo', '🥩'),
    ('Thai', 'Gaeng_Som', '🍲'),
    ('Thai', 'Khao_Tom', '🍚'),
    ('Thai', 'Tod_Mun_Pla', '🐟'),
    ('Thai', 'Bua_Loy', '🟣'),
    ('Mediterranean', 'Moussaka', '🍆'),
    ('Mediterranean', 'Hummus', '🫘'),
    ('Mediterranean', 'Falafel', '🧆'),
    ('Mediterranean', 'Tabbouleh', '🥗'),
    ('Mediterranean', 'Paella', '🥘'),
    ('Mediterranean', 'Shawarma', '🌯'),
    ('Mediterranean', 'Spanakopita', '🥧'),
    ('Mediterranean', 'Tzatziki', '🥒'),
    ('Mediterranean', 'Baklava', '🍯'),
    ('Mediterranean', 'Souvlaki', '🍢'),
    ('Mediterranean', 'Kibbeh', '🧆'),
    ('Mediterranean', 'Shakshuka', '🍳'),
    ('Mediterranean', 'Baba_Ganoush', '🍆'),
    ('Mediterranean', 'Fattoush', '🥗'),
    ('Mediterranean', 'Borek', '🥧'),
    ('Mediterranean', 'Dolmades', '🍃'),
    ('Mediterranean', 'Imam_Bayildi', '🍆'),
    ('Mediterranean', 'Kleftiko', '🐑'),
    ('Mediterranean', 'Gazpacho', '🍅'),
    ('Mediterranean', 'Labneh', '🥛'),
    ('Mediterranean', 'Couscous_Royal', '🍛'),
    ('Mediterranean', 'Pastilla', '🥧'),
    ('Mediterranean', 'Fatayer', '🫓'),
    ('Mediterranean', 'Grilled_Octopus', '🐙'),
    ('Mediterranean', 'Loukoumades', '🍩')
ON CONFLICT (dish) DO NOTHING;

-- Seed recipe_ingredients
INSERT INTO recipe_ingredients (recipe_id, ingredient_id)
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ramen' AND i.name = 'noodles'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ramen' AND i.name = 'pork_broth'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ramen' AND i.name = 'soy_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ramen' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ramen' AND i.name = 'ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ramen' AND i.name = 'soft_boiled_egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ramen' AND i.name = 'green_onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ramen' AND i.name = 'nori'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sushi' AND i.name = 'sushi_rice'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sushi' AND i.name = 'nori'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sushi' AND i.name = 'salmon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sushi' AND i.name = 'tuna'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sushi' AND i.name = 'avocado'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sushi' AND i.name = 'soy_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sushi' AND i.name = 'wasabi'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sushi' AND i.name = 'pickled_ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kung_Pao_Chicken' AND i.name = 'chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kung_Pao_Chicken' AND i.name = 'peanuts'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kung_Pao_Chicken' AND i.name = 'dried_chiles'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kung_Pao_Chicken' AND i.name = 'soy_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kung_Pao_Chicken' AND i.name = 'rice_vinegar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kung_Pao_Chicken' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kung_Pao_Chicken' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kung_Pao_Chicken' AND i.name = 'ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bibimbap' AND i.name = 'short_grain_rice'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bibimbap' AND i.name = 'beef'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bibimbap' AND i.name = 'spinach'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bibimbap' AND i.name = 'bean_sprouts'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bibimbap' AND i.name = 'carrot'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bibimbap' AND i.name = 'gochujang'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bibimbap' AND i.name = 'sesame_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bibimbap' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Thai' AND i.name = 'rice_noodles'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Thai' AND i.name = 'shrimp'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Thai' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Thai' AND i.name = 'bean_sprouts'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Thai' AND i.name = 'peanuts'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Thai' AND i.name = 'fish_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Thai' AND i.name = 'tamarind'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Thai' AND i.name = 'lime'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dim_Sum' AND i.name = 'shrimp'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dim_Sum' AND i.name = 'pork'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dim_Sum' AND i.name = 'dumpling_wrappers'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dim_Sum' AND i.name = 'ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dim_Sum' AND i.name = 'soy_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dim_Sum' AND i.name = 'sesame_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dim_Sum' AND i.name = 'green_onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dim_Sum' AND i.name = 'bamboo_shoots'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bulgogi' AND i.name = 'beef'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bulgogi' AND i.name = 'soy_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bulgogi' AND i.name = 'pear'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bulgogi' AND i.name = 'sesame_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bulgogi' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bulgogi' AND i.name = 'ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bulgogi' AND i.name = 'green_onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bulgogi' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pho' AND i.name = 'rice_noodles'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pho' AND i.name = 'beef'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pho' AND i.name = 'bone_broth'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pho' AND i.name = 'star_anise'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pho' AND i.name = 'ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pho' AND i.name = 'cinnamon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pho' AND i.name = 'basil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pho' AND i.name = 'bean_sprouts'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gyoza' AND i.name = 'pork'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gyoza' AND i.name = 'cabbage'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gyoza' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gyoza' AND i.name = 'ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gyoza' AND i.name = 'soy_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gyoza' AND i.name = 'sesame_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gyoza' AND i.name = 'dumpling_wrappers'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gyoza' AND i.name = 'green_onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Char_Siu' AND i.name = 'pork_shoulder'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Char_Siu' AND i.name = 'hoisin_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Char_Siu' AND i.name = 'soy_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Char_Siu' AND i.name = 'honey'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Char_Siu' AND i.name = 'five_spice'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Char_Siu' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Char_Siu' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Char_Siu' AND i.name = 'shaoxing_wine'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Peking_Duck' AND i.name = 'whole_duck'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Peking_Duck' AND i.name = 'hoisin_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Peking_Duck' AND i.name = 'chinese_pancake'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Peking_Duck' AND i.name = 'cucumber'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Peking_Duck' AND i.name = 'green_onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Peking_Duck' AND i.name = 'soy_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Peking_Duck' AND i.name = 'five_spice'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Peking_Duck' AND i.name = 'honey'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Japchae' AND i.name = 'glass_noodles'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Japchae' AND i.name = 'beef'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Japchae' AND i.name = 'spinach'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Japchae' AND i.name = 'mushroom'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Japchae' AND i.name = 'carrot'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Japchae' AND i.name = 'soy_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Japchae' AND i.name = 'sesame_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Japchae' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Banh_Mi' AND i.name = 'baguette'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Banh_Mi' AND i.name = 'pork'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Banh_Mi' AND i.name = 'pate'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Banh_Mi' AND i.name = 'pickled_daikon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Banh_Mi' AND i.name = 'cilantro'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Banh_Mi' AND i.name = 'jalapeño'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Banh_Mi' AND i.name = 'mayo'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Banh_Mi' AND i.name = 'soy_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mapo_Tofu' AND i.name = 'soft_tofu'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mapo_Tofu' AND i.name = 'ground_pork'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mapo_Tofu' AND i.name = 'doubanjiang'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mapo_Tofu' AND i.name = 'sichuan_pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mapo_Tofu' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mapo_Tofu' AND i.name = 'ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mapo_Tofu' AND i.name = 'broth'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mapo_Tofu' AND i.name = 'green_onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tteokbokki' AND i.name = 'rice_cakes'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tteokbokki' AND i.name = 'gochujang'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tteokbokki' AND i.name = 'fish_cake'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tteokbokki' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tteokbokki' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tteokbokki' AND i.name = 'green_onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tteokbokki' AND i.name = 'broth'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tteokbokki' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Nasi_Goreng' AND i.name = 'cooked_rice'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Nasi_Goreng' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Nasi_Goreng' AND i.name = 'shrimp'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Nasi_Goreng' AND i.name = 'soy_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Nasi_Goreng' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Nasi_Goreng' AND i.name = 'shallot'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Nasi_Goreng' AND i.name = 'chili'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Nasi_Goreng' AND i.name = 'kecap_manis'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Laksa' AND i.name = 'rice_noodles'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Laksa' AND i.name = 'shrimp'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Laksa' AND i.name = 'coconut_milk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Laksa' AND i.name = 'laksa_paste'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Laksa' AND i.name = 'tofu_puffs'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Laksa' AND i.name = 'bean_sprouts'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Laksa' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Laksa' AND i.name = 'lime'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tempura' AND i.name = 'shrimp'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tempura' AND i.name = 'sweet_potato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tempura' AND i.name = 'flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tempura' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tempura' AND i.name = 'ice_water'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tempura' AND i.name = 'dashi'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tempura' AND i.name = 'mirin'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tempura' AND i.name = 'soy_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Miso_Soup' AND i.name = 'dashi'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Miso_Soup' AND i.name = 'miso_paste'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Miso_Soup' AND i.name = 'tofu'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Miso_Soup' AND i.name = 'wakame'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Miso_Soup' AND i.name = 'green_onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Miso_Soup' AND i.name = 'mushroom'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Miso_Soup' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Miso_Soup' AND i.name = 'water'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hot_Pot' AND i.name = 'beef_broth'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hot_Pot' AND i.name = 'beef_slices'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hot_Pot' AND i.name = 'tofu'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hot_Pot' AND i.name = 'mushroom'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hot_Pot' AND i.name = 'napa_cabbage'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hot_Pot' AND i.name = 'sesame_paste'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hot_Pot' AND i.name = 'sichuan_pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hot_Pot' AND i.name = 'glass_noodles'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rendang' AND i.name = 'beef'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rendang' AND i.name = 'coconut_milk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rendang' AND i.name = 'lemongrass'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rendang' AND i.name = 'galangal'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rendang' AND i.name = 'turmeric'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rendang' AND i.name = 'dried_chiles'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rendang' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rendang' AND i.name = 'kaffir_lime'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Spring_Rolls' AND i.name = 'rice_paper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Spring_Rolls' AND i.name = 'shrimp'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Spring_Rolls' AND i.name = 'pork'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Spring_Rolls' AND i.name = 'vermicelli'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Spring_Rolls' AND i.name = 'lettuce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Spring_Rolls' AND i.name = 'mint'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Spring_Rolls' AND i.name = 'cilantro'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Spring_Rolls' AND i.name = 'peanut_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Okonomiyaki' AND i.name = 'flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Okonomiyaki' AND i.name = 'cabbage'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Okonomiyaki' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Okonomiyaki' AND i.name = 'pork_belly'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Okonomiyaki' AND i.name = 'bonito_flakes'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Okonomiyaki' AND i.name = 'mayo'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Okonomiyaki' AND i.name = 'okonomiyaki_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Okonomiyaki' AND i.name = 'green_onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Takoyaki' AND i.name = 'octopus'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Takoyaki' AND i.name = 'flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Takoyaki' AND i.name = 'dashi'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Takoyaki' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Takoyaki' AND i.name = 'green_onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Takoyaki' AND i.name = 'pickled_ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Takoyaki' AND i.name = 'mayo'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Takoyaki' AND i.name = 'bonito_flakes'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Yakitori' AND i.name = 'chicken_thighs'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Yakitori' AND i.name = 'soy_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Yakitori' AND i.name = 'mirin'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Yakitori' AND i.name = 'sake'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Yakitori' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Yakitori' AND i.name = 'green_onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Yakitori' AND i.name = 'sesame'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Yakitori' AND i.name = 'ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Butter_Chicken' AND i.name = 'chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Butter_Chicken' AND i.name = 'tomato_puree'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Butter_Chicken' AND i.name = 'cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Butter_Chicken' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Butter_Chicken' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Butter_Chicken' AND i.name = 'ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Butter_Chicken' AND i.name = 'garam_masala'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Butter_Chicken' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Biryani' AND i.name = 'basmati_rice'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Biryani' AND i.name = 'chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Biryani' AND i.name = 'yogurt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Biryani' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Biryani' AND i.name = 'saffron'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Biryani' AND i.name = 'ghee'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Biryani' AND i.name = 'fried_onions'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Biryani' AND i.name = 'whole_spices'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dal_Tadka' AND i.name = 'yellow_lentils'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dal_Tadka' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dal_Tadka' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dal_Tadka' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dal_Tadka' AND i.name = 'ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dal_Tadka' AND i.name = 'turmeric'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dal_Tadka' AND i.name = 'cumin'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dal_Tadka' AND i.name = 'ghee'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Palak_Paneer' AND i.name = 'spinach'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Palak_Paneer' AND i.name = 'paneer'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Palak_Paneer' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Palak_Paneer' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Palak_Paneer' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Palak_Paneer' AND i.name = 'ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Palak_Paneer' AND i.name = 'cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Palak_Paneer' AND i.name = 'garam_masala'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Samosa' AND i.name = 'potato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Samosa' AND i.name = 'green_peas'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Samosa' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Samosa' AND i.name = 'ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Samosa' AND i.name = 'cumin'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Samosa' AND i.name = 'coriander'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Samosa' AND i.name = 'pastry_dough'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Samosa' AND i.name = 'oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chicken_Tikka_Masala' AND i.name = 'chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chicken_Tikka_Masala' AND i.name = 'yogurt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chicken_Tikka_Masala' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chicken_Tikka_Masala' AND i.name = 'cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chicken_Tikka_Masala' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chicken_Tikka_Masala' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chicken_Tikka_Masala' AND i.name = 'ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chicken_Tikka_Masala' AND i.name = 'tikka_spices'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Naan' AND i.name = 'all_purpose_flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Naan' AND i.name = 'yogurt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Naan' AND i.name = 'yeast'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Naan' AND i.name = 'ghee'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Naan' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Naan' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Naan' AND i.name = 'milk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Naan' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chana_Masala' AND i.name = 'chickpeas'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chana_Masala' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chana_Masala' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chana_Masala' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chana_Masala' AND i.name = 'ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chana_Masala' AND i.name = 'cumin'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chana_Masala' AND i.name = 'coriander'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chana_Masala' AND i.name = 'amchur'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Korma' AND i.name = 'chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Korma' AND i.name = 'yogurt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Korma' AND i.name = 'cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Korma' AND i.name = 'cashews'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Korma' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Korma' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Korma' AND i.name = 'cardamom'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Korma' AND i.name = 'saffron'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Aloo_Gobi' AND i.name = 'potato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Aloo_Gobi' AND i.name = 'cauliflower'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Aloo_Gobi' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Aloo_Gobi' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Aloo_Gobi' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Aloo_Gobi' AND i.name = 'ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Aloo_Gobi' AND i.name = 'turmeric'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Aloo_Gobi' AND i.name = 'cumin'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rogan_Josh' AND i.name = 'lamb'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rogan_Josh' AND i.name = 'yogurt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rogan_Josh' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rogan_Josh' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rogan_Josh' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rogan_Josh' AND i.name = 'ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rogan_Josh' AND i.name = 'kashmiri_chili'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rogan_Josh' AND i.name = 'whole_spices'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dosa' AND i.name = 'rice'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dosa' AND i.name = 'urad_dal'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dosa' AND i.name = 'fenugreek'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dosa' AND i.name = 'oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dosa' AND i.name = 'potato_filling'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dosa' AND i.name = 'mustard_seeds'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dosa' AND i.name = 'curry_leaves'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dosa' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Idli' AND i.name = 'rice'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Idli' AND i.name = 'urad_dal'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Idli' AND i.name = 'fenugreek'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Idli' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Idli' AND i.name = 'water'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Idli' AND i.name = 'coconut_chutney'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Idli' AND i.name = 'sambar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Idli' AND i.name = 'ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chole_Bhature' AND i.name = 'chickpeas'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chole_Bhature' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chole_Bhature' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chole_Bhature' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chole_Bhature' AND i.name = 'ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chole_Bhature' AND i.name = 'garam_masala'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chole_Bhature' AND i.name = 'bhatura_dough'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chole_Bhature' AND i.name = 'oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pav_Bhaji' AND i.name = 'potato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pav_Bhaji' AND i.name = 'mixed_vegetables'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pav_Bhaji' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pav_Bhaji' AND i.name = 'pav_bun'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pav_Bhaji' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pav_Bhaji' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pav_Bhaji' AND i.name = 'pav_bhaji_masala'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pav_Bhaji' AND i.name = 'lemon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Saag_Paneer' AND i.name = 'mustard_greens'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Saag_Paneer' AND i.name = 'spinach'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Saag_Paneer' AND i.name = 'paneer'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Saag_Paneer' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Saag_Paneer' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Saag_Paneer' AND i.name = 'ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Saag_Paneer' AND i.name = 'cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Saag_Paneer' AND i.name = 'spices'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gulab_Jamun' AND i.name = 'milk_powder'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gulab_Jamun' AND i.name = 'flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gulab_Jamun' AND i.name = 'ghee'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gulab_Jamun' AND i.name = 'sugar_syrup'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gulab_Jamun' AND i.name = 'cardamom'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gulab_Jamun' AND i.name = 'rose_water'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gulab_Jamun' AND i.name = 'saffron'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gulab_Jamun' AND i.name = 'oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kheer' AND i.name = 'basmati_rice'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kheer' AND i.name = 'whole_milk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kheer' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kheer' AND i.name = 'cardamom'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kheer' AND i.name = 'saffron'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kheer' AND i.name = 'pistachios'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kheer' AND i.name = 'almonds'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kheer' AND i.name = 'rose_water'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tandoori_Chicken' AND i.name = 'chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tandoori_Chicken' AND i.name = 'yogurt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tandoori_Chicken' AND i.name = 'tandoori_masala'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tandoori_Chicken' AND i.name = 'lemon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tandoori_Chicken' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tandoori_Chicken' AND i.name = 'ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tandoori_Chicken' AND i.name = 'oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tandoori_Chicken' AND i.name = 'red_chili'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Vindaloo' AND i.name = 'pork'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Vindaloo' AND i.name = 'vinegar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Vindaloo' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Vindaloo' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Vindaloo' AND i.name = 'ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Vindaloo' AND i.name = 'dried_chiles'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Vindaloo' AND i.name = 'cumin'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Vindaloo' AND i.name = 'mustard_seeds'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Malai_Kofta' AND i.name = 'paneer'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Malai_Kofta' AND i.name = 'potato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Malai_Kofta' AND i.name = 'cream_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Malai_Kofta' AND i.name = 'cashew'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Malai_Kofta' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Malai_Kofta' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Malai_Kofta' AND i.name = 'cardamom'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Malai_Kofta' AND i.name = 'saffron'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dhansak' AND i.name = 'lentils'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dhansak' AND i.name = 'lamb'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dhansak' AND i.name = 'pumpkin'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dhansak' AND i.name = 'spinach'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dhansak' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dhansak' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dhansak' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dhansak' AND i.name = 'dhansak_masala'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pani_Puri' AND i.name = 'semolina_puri'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pani_Puri' AND i.name = 'spiced_water'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pani_Puri' AND i.name = 'tamarind_chutney'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pani_Puri' AND i.name = 'potato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pani_Puri' AND i.name = 'chickpeas'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pani_Puri' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pani_Puri' AND i.name = 'cilantro'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pani_Puri' AND i.name = 'chaat_masala'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bhindi_Masala' AND i.name = 'okra'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bhindi_Masala' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bhindi_Masala' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bhindi_Masala' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bhindi_Masala' AND i.name = 'ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bhindi_Masala' AND i.name = 'cumin'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bhindi_Masala' AND i.name = 'coriander'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bhindi_Masala' AND i.name = 'amchur'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mishti_Doi' AND i.name = 'whole_milk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mishti_Doi' AND i.name = 'yogurt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mishti_Doi' AND i.name = 'jaggery'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mishti_Doi' AND i.name = 'cardamom'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mishti_Doi' AND i.name = 'saffron'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mishti_Doi' AND i.name = 'rose_water'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mishti_Doi' AND i.name = 'cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mishti_Doi' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pizza_Margherita' AND i.name = 'pizza_dough'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pizza_Margherita' AND i.name = 'tomato_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pizza_Margherita' AND i.name = 'fresh_mozzarella'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pizza_Margherita' AND i.name = 'basil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pizza_Margherita' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pizza_Margherita' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pizza_Margherita' AND i.name = 'yeast'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pizza_Margherita' AND i.name = 'flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pasta_Carbonara' AND i.name = 'spaghetti'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pasta_Carbonara' AND i.name = 'eggs'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pasta_Carbonara' AND i.name = 'guanciale'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pasta_Carbonara' AND i.name = 'pecorino_romano'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pasta_Carbonara' AND i.name = 'black_pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pasta_Carbonara' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pasta_Carbonara' AND i.name = 'parsley'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pasta_Carbonara' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Risotto_Milanese' AND i.name = 'arborio_rice'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Risotto_Milanese' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Risotto_Milanese' AND i.name = 'white_wine'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Risotto_Milanese' AND i.name = 'parmesan'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Risotto_Milanese' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Risotto_Milanese' AND i.name = 'beef_broth'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Risotto_Milanese' AND i.name = 'saffron'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Risotto_Milanese' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Lasagna' AND i.name = 'lasagna_sheets'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Lasagna' AND i.name = 'ground_beef'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Lasagna' AND i.name = 'tomato_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Lasagna' AND i.name = 'bechamel'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Lasagna' AND i.name = 'mozzarella'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Lasagna' AND i.name = 'parmesan'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Lasagna' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Lasagna' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tiramisu' AND i.name = 'mascarpone'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tiramisu' AND i.name = 'eggs'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tiramisu' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tiramisu' AND i.name = 'espresso'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tiramisu' AND i.name = 'savoiardi'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tiramisu' AND i.name = 'cocoa_powder'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tiramisu' AND i.name = 'marsala'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tiramisu' AND i.name = 'cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Osso_Buco' AND i.name = 'veal_shank'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Osso_Buco' AND i.name = 'white_wine'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Osso_Buco' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Osso_Buco' AND i.name = 'carrot'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Osso_Buco' AND i.name = 'celery'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Osso_Buco' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Osso_Buco' AND i.name = 'beef_broth'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Osso_Buco' AND i.name = 'gremolata'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bruschetta' AND i.name = 'sourdough_bread'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bruschetta' AND i.name = 'ripe_tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bruschetta' AND i.name = 'basil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bruschetta' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bruschetta' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bruschetta' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bruschetta' AND i.name = 'pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bruschetta' AND i.name = 'balsamic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Minestrone' AND i.name = 'cannellini_beans'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Minestrone' AND i.name = 'pasta'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Minestrone' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Minestrone' AND i.name = 'zucchini'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Minestrone' AND i.name = 'carrot'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Minestrone' AND i.name = 'celery'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Minestrone' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Minestrone' AND i.name = 'parmesan'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gnocchi' AND i.name = 'potato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gnocchi' AND i.name = 'flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gnocchi' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gnocchi' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gnocchi' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gnocchi' AND i.name = 'sage'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gnocchi' AND i.name = 'parmesan'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gnocchi' AND i.name = 'nutmeg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Panna_Cotta' AND i.name = 'heavy_cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Panna_Cotta' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Panna_Cotta' AND i.name = 'gelatin'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Panna_Cotta' AND i.name = 'vanilla'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Panna_Cotta' AND i.name = 'mixed_berries'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Panna_Cotta' AND i.name = 'lemon_zest'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Panna_Cotta' AND i.name = 'milk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Panna_Cotta' AND i.name = 'honey'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Saltimbocca' AND i.name = 'veal'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Saltimbocca' AND i.name = 'prosciutto'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Saltimbocca' AND i.name = 'sage'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Saltimbocca' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Saltimbocca' AND i.name = 'white_wine'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Saltimbocca' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Saltimbocca' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Saltimbocca' AND i.name = 'pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Arancini' AND i.name = 'risotto_rice'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Arancini' AND i.name = 'mozzarella'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Arancini' AND i.name = 'ground_beef'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Arancini' AND i.name = 'peas'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Arancini' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Arancini' AND i.name = 'breadcrumbs'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Arancini' AND i.name = 'tomato_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Arancini' AND i.name = 'parmesan'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cacio_e_Pepe' AND i.name = 'spaghetti'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cacio_e_Pepe' AND i.name = 'pecorino_romano'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cacio_e_Pepe' AND i.name = 'black_pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cacio_e_Pepe' AND i.name = 'pasta_water'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cacio_e_Pepe' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cacio_e_Pepe' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cacio_e_Pepe' AND i.name = 'parmesan'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cacio_e_Pepe' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Focaccia' AND i.name = 'flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Focaccia' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Focaccia' AND i.name = 'yeast'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Focaccia' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Focaccia' AND i.name = 'rosemary'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Focaccia' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Focaccia' AND i.name = 'water'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Focaccia' AND i.name = 'sea_salt_flakes'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ribollita' AND i.name = 'cannellini_beans'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ribollita' AND i.name = 'kale'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ribollita' AND i.name = 'bread'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ribollita' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ribollita' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ribollita' AND i.name = 'carrot'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ribollita' AND i.name = 'celery'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ribollita' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bistecca_Fiorentina' AND i.name = 't_bone_steak'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bistecca_Fiorentina' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bistecca_Fiorentina' AND i.name = 'rosemary'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bistecca_Fiorentina' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bistecca_Fiorentina' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bistecca_Fiorentina' AND i.name = 'black_pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bistecca_Fiorentina' AND i.name = 'lemon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bistecca_Fiorentina' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pesto_Pasta' AND i.name = 'pasta'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pesto_Pasta' AND i.name = 'basil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pesto_Pasta' AND i.name = 'pine_nuts'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pesto_Pasta' AND i.name = 'parmesan'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pesto_Pasta' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pesto_Pasta' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pesto_Pasta' AND i.name = 'lemon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pesto_Pasta' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Frittata' AND i.name = 'eggs'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Frittata' AND i.name = 'zucchini'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Frittata' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Frittata' AND i.name = 'parmesan'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Frittata' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Frittata' AND i.name = 'basil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Frittata' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Frittata' AND i.name = 'pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cannoli' AND i.name = 'pastry_shells'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cannoli' AND i.name = 'ricotta'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cannoli' AND i.name = 'powdered_sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cannoli' AND i.name = 'chocolate_chips'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cannoli' AND i.name = 'pistachios'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cannoli' AND i.name = 'orange_zest'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cannoli' AND i.name = 'vanilla'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cannoli' AND i.name = 'cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Caponata' AND i.name = 'eggplant'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Caponata' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Caponata' AND i.name = 'celery'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Caponata' AND i.name = 'olives'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Caponata' AND i.name = 'capers'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Caponata' AND i.name = 'vinegar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Caponata' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Caponata' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Supplì' AND i.name = 'risotto_rice'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Supplì' AND i.name = 'mozzarella'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Supplì' AND i.name = 'tomato_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Supplì' AND i.name = 'ground_beef'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Supplì' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Supplì' AND i.name = 'breadcrumbs'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Supplì' AND i.name = 'parmesan'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Supplì' AND i.name = 'oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Amatriciana' AND i.name = 'bucatini'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Amatriciana' AND i.name = 'guanciale'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Amatriciana' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Amatriciana' AND i.name = 'pecorino'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Amatriciana' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Amatriciana' AND i.name = 'white_wine'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Amatriciana' AND i.name = 'chili_flakes'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Amatriciana' AND i.name = 'black_pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Panzanella' AND i.name = 'stale_bread'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Panzanella' AND i.name = 'ripe_tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Panzanella' AND i.name = 'cucumber'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Panzanella' AND i.name = 'red_onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Panzanella' AND i.name = 'basil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Panzanella' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Panzanella' AND i.name = 'red_wine_vinegar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Panzanella' AND i.name = 'capers'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ribollita_Toscana' AND i.name = 'cannellini_beans'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ribollita_Toscana' AND i.name = 'cavolo_nero'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ribollita_Toscana' AND i.name = 'stale_bread'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ribollita_Toscana' AND i.name = 'carrot'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ribollita_Toscana' AND i.name = 'celery'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ribollita_Toscana' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ribollita_Toscana' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ribollita_Toscana' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Zabaglione' AND i.name = 'egg_yolks'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Zabaglione' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Zabaglione' AND i.name = 'marsala_wine'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Zabaglione' AND i.name = 'cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Zabaglione' AND i.name = 'vanilla'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Zabaglione' AND i.name = 'berries'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Zabaglione' AND i.name = 'lemon_zest'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Zabaglione' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tacos_al_Pastor' AND i.name = 'pork_shoulder'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tacos_al_Pastor' AND i.name = 'pineapple'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tacos_al_Pastor' AND i.name = 'achiote'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tacos_al_Pastor' AND i.name = 'corn_tortilla'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tacos_al_Pastor' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tacos_al_Pastor' AND i.name = 'cilantro'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tacos_al_Pastor' AND i.name = 'lime'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tacos_al_Pastor' AND i.name = 'salsa_verde'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Guacamole' AND i.name = 'avocado'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Guacamole' AND i.name = 'lime'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Guacamole' AND i.name = 'cilantro'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Guacamole' AND i.name = 'white_onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Guacamole' AND i.name = 'jalapeño'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Guacamole' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Guacamole' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Guacamole' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Enchiladas' AND i.name = 'corn_tortilla'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Enchiladas' AND i.name = 'chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Enchiladas' AND i.name = 'red_enchilada_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Enchiladas' AND i.name = 'oaxaca_cheese'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Enchiladas' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Enchiladas' AND i.name = 'sour_cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Enchiladas' AND i.name = 'cilantro'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Enchiladas' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chiles_Rellenos' AND i.name = 'poblano_pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chiles_Rellenos' AND i.name = 'oaxaca_cheese'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chiles_Rellenos' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chiles_Rellenos' AND i.name = 'flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chiles_Rellenos' AND i.name = 'tomato_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chiles_Rellenos' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chiles_Rellenos' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chiles_Rellenos' AND i.name = 'cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pozole_Rojo' AND i.name = 'pork'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pozole_Rojo' AND i.name = 'hominy'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pozole_Rojo' AND i.name = 'dried_guajillo'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pozole_Rojo' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pozole_Rojo' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pozole_Rojo' AND i.name = 'oregano'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pozole_Rojo' AND i.name = 'cabbage'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pozole_Rojo' AND i.name = 'radish'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tamales' AND i.name = 'masa_harina'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tamales' AND i.name = 'pork'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tamales' AND i.name = 'red_chile_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tamales' AND i.name = 'lard'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tamales' AND i.name = 'corn_husks'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tamales' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tamales' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tamales' AND i.name = 'cumin'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Quesadillas' AND i.name = 'flour_tortilla'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Quesadillas' AND i.name = 'oaxaca_cheese'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Quesadillas' AND i.name = 'chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Quesadillas' AND i.name = 'jalapeño'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Quesadillas' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Quesadillas' AND i.name = 'salsa'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Quesadillas' AND i.name = 'sour_cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Quesadillas' AND i.name = 'cilantro'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mole_Negro' AND i.name = 'turkey'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mole_Negro' AND i.name = 'dried_chiles'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mole_Negro' AND i.name = 'dark_chocolate'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mole_Negro' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mole_Negro' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mole_Negro' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mole_Negro' AND i.name = 'spices'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mole_Negro' AND i.name = 'sesame'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ceviche' AND i.name = 'white_fish'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ceviche' AND i.name = 'lime_juice'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ceviche' AND i.name = 'red_onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ceviche' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ceviche' AND i.name = 'cilantro'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ceviche' AND i.name = 'serrano'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ceviche' AND i.name = 'avocado'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ceviche' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Churros' AND i.name = 'flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Churros' AND i.name = 'water'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Churros' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Churros' AND i.name = 'cinnamon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Churros' AND i.name = 'oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Churros' AND i.name = 'vanilla'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Churros' AND i.name = 'chocolate_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Churros' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sopa_de_Lima' AND i.name = 'chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sopa_de_Lima' AND i.name = 'lime'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sopa_de_Lima' AND i.name = 'tortilla_strips'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sopa_de_Lima' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sopa_de_Lima' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sopa_de_Lima' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sopa_de_Lima' AND i.name = 'cilantro'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sopa_de_Lima' AND i.name = 'habanero'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Huevos_Rancheros' AND i.name = 'eggs'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Huevos_Rancheros' AND i.name = 'corn_tortilla'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Huevos_Rancheros' AND i.name = 'ranchero_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Huevos_Rancheros' AND i.name = 'black_beans'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Huevos_Rancheros' AND i.name = 'queso_fresco'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Huevos_Rancheros' AND i.name = 'cilantro'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Huevos_Rancheros' AND i.name = 'avocado'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Huevos_Rancheros' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Carnitas' AND i.name = 'pork_shoulder'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Carnitas' AND i.name = 'orange_juice'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Carnitas' AND i.name = 'lard'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Carnitas' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Carnitas' AND i.name = 'cumin'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Carnitas' AND i.name = 'bay_leaf'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Carnitas' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Carnitas' AND i.name = 'oregano'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Elote' AND i.name = 'corn'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Elote' AND i.name = 'mayo'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Elote' AND i.name = 'cotija_cheese'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Elote' AND i.name = 'chili_powder'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Elote' AND i.name = 'lime'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Elote' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Elote' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Elote' AND i.name = 'cilantro'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Birria' AND i.name = 'beef'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Birria' AND i.name = 'dried_chiles'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Birria' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Birria' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Birria' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Birria' AND i.name = 'cumin'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Birria' AND i.name = 'cinnamon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Birria' AND i.name = 'tortilla'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Flautas' AND i.name = 'corn_tortilla'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Flautas' AND i.name = 'shredded_chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Flautas' AND i.name = 'oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Flautas' AND i.name = 'sour_cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Flautas' AND i.name = 'salsa'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Flautas' AND i.name = 'lettuce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Flautas' AND i.name = 'cotija'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Flautas' AND i.name = 'avocado'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cochinita_Pibil' AND i.name = 'pork'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cochinita_Pibil' AND i.name = 'achiote_paste'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cochinita_Pibil' AND i.name = 'orange_juice'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cochinita_Pibil' AND i.name = 'lime'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cochinita_Pibil' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cochinita_Pibil' AND i.name = 'cumin'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cochinita_Pibil' AND i.name = 'habanero'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cochinita_Pibil' AND i.name = 'banana_leaf'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sopes' AND i.name = 'masa'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sopes' AND i.name = 'refried_beans'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sopes' AND i.name = 'chorizo'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sopes' AND i.name = 'lettuce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sopes' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sopes' AND i.name = 'queso_fresco'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sopes' AND i.name = 'sour_cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sopes' AND i.name = 'salsa'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Menudo' AND i.name = 'beef_tripe'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Menudo' AND i.name = 'hominy'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Menudo' AND i.name = 'dried_chiles'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Menudo' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Menudo' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Menudo' AND i.name = 'oregano'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Menudo' AND i.name = 'lime'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Menudo' AND i.name = 'cilantro'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tostadas' AND i.name = 'tostada_shell'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tostadas' AND i.name = 'refried_beans'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tostadas' AND i.name = 'shredded_chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tostadas' AND i.name = 'lettuce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tostadas' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tostadas' AND i.name = 'sour_cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tostadas' AND i.name = 'avocado'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tostadas' AND i.name = 'cotija'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Agua_Fresca' AND i.name = 'watermelon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Agua_Fresca' AND i.name = 'lime'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Agua_Fresca' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Agua_Fresca' AND i.name = 'water'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Agua_Fresca' AND i.name = 'mint'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Agua_Fresca' AND i.name = 'cucumber'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Agua_Fresca' AND i.name = 'chili_powder'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Agua_Fresca' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Arroz_con_Leche' AND i.name = 'rice'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Arroz_con_Leche' AND i.name = 'whole_milk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Arroz_con_Leche' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Arroz_con_Leche' AND i.name = 'cinnamon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Arroz_con_Leche' AND i.name = 'vanilla'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Arroz_con_Leche' AND i.name = 'lime_zest'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Arroz_con_Leche' AND i.name = 'raisins'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Arroz_con_Leche' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chiles_en_Nogada' AND i.name = 'poblano_pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chiles_en_Nogada' AND i.name = 'ground_pork'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chiles_en_Nogada' AND i.name = 'fruit_filling'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chiles_en_Nogada' AND i.name = 'walnut_cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chiles_en_Nogada' AND i.name = 'pomegranate'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chiles_en_Nogada' AND i.name = 'parsley'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chiles_en_Nogada' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Chiles_en_Nogada' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tlayuda' AND i.name = 'corn_tortilla'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tlayuda' AND i.name = 'black_beans'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tlayuda' AND i.name = 'tasajo'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tlayuda' AND i.name = 'oaxaca_cheese'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tlayuda' AND i.name = 'avocado'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tlayuda' AND i.name = 'cabbage'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tlayuda' AND i.name = 'salsa'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tlayuda' AND i.name = 'lard'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pepián_Verde' AND i.name = 'chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pepián_Verde' AND i.name = 'pumpkin_seeds'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pepián_Verde' AND i.name = 'tomatillo'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pepián_Verde' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pepián_Verde' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pepián_Verde' AND i.name = 'jalapeño'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pepián_Verde' AND i.name = 'cilantro'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pepián_Verde' AND i.name = 'epazote'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Croissant' AND i.name = 'all_purpose_flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Croissant' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Croissant' AND i.name = 'yeast'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Croissant' AND i.name = 'whole_milk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Croissant' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Croissant' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Croissant' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Croissant' AND i.name = 'water'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Coq_au_Vin' AND i.name = 'chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Coq_au_Vin' AND i.name = 'red_burgundy'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Coq_au_Vin' AND i.name = 'button_mushrooms'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Coq_au_Vin' AND i.name = 'lardons'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Coq_au_Vin' AND i.name = 'pearl_onions'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Coq_au_Vin' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Coq_au_Vin' AND i.name = 'thyme'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Coq_au_Vin' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Boeuf_Bourguignon' AND i.name = 'beef_chuck'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Boeuf_Bourguignon' AND i.name = 'pinot_noir'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Boeuf_Bourguignon' AND i.name = 'cremini_mushrooms'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Boeuf_Bourguignon' AND i.name = 'lardons'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Boeuf_Bourguignon' AND i.name = 'pearl_onions'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Boeuf_Bourguignon' AND i.name = 'carrot'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Boeuf_Bourguignon' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Boeuf_Bourguignon' AND i.name = 'thyme'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ratatouille' AND i.name = 'eggplant'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ratatouille' AND i.name = 'zucchini'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ratatouille' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ratatouille' AND i.name = 'red_bell_pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ratatouille' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ratatouille' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ratatouille' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Ratatouille' AND i.name = 'herbes_de_provence'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Crème_Brûlée' AND i.name = 'heavy_cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Crème_Brûlée' AND i.name = 'egg_yolks'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Crème_Brûlée' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Crème_Brûlée' AND i.name = 'vanilla_bean'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Crème_Brûlée' AND i.name = 'milk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Crème_Brûlée' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Crème_Brûlée' AND i.name = 'caramel'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Crème_Brûlée' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Quiche_Lorraine' AND i.name = 'eggs'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Quiche_Lorraine' AND i.name = 'heavy_cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Quiche_Lorraine' AND i.name = 'lardons'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Quiche_Lorraine' AND i.name = 'gruyere'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Quiche_Lorraine' AND i.name = 'shortcrust_pastry'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Quiche_Lorraine' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Quiche_Lorraine' AND i.name = 'nutmeg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Quiche_Lorraine' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'French_Onion_Soup' AND i.name = 'yellow_onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'French_Onion_Soup' AND i.name = 'beef_broth'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'French_Onion_Soup' AND i.name = 'gruyere'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'French_Onion_Soup' AND i.name = 'baguette'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'French_Onion_Soup' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'French_Onion_Soup' AND i.name = 'dry_white_wine'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'French_Onion_Soup' AND i.name = 'thyme'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'French_Onion_Soup' AND i.name = 'bay_leaf'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bouillabaisse' AND i.name = 'mixed_fish'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bouillabaisse' AND i.name = 'mussels'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bouillabaisse' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bouillabaisse' AND i.name = 'saffron'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bouillabaisse' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bouillabaisse' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bouillabaisse' AND i.name = 'fennel'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bouillabaisse' AND i.name = 'rouille'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Duck_Confit' AND i.name = 'duck_legs'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Duck_Confit' AND i.name = 'duck_fat'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Duck_Confit' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Duck_Confit' AND i.name = 'thyme'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Duck_Confit' AND i.name = 'bay_leaf'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Duck_Confit' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Duck_Confit' AND i.name = 'black_pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Duck_Confit' AND i.name = 'rosemary'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tarte_Tatin' AND i.name = 'golden_apples'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tarte_Tatin' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tarte_Tatin' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tarte_Tatin' AND i.name = 'puff_pastry'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tarte_Tatin' AND i.name = 'caramel'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tarte_Tatin' AND i.name = 'vanilla'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tarte_Tatin' AND i.name = 'cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tarte_Tatin' AND i.name = 'lemon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Soupe_à_l''Oignon' AND i.name = 'white_onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Soupe_à_l''Oignon' AND i.name = 'beef_stock'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Soupe_à_l''Oignon' AND i.name = 'emmental'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Soupe_à_l''Oignon' AND i.name = 'baguette'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Soupe_à_l''Oignon' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Soupe_à_l''Oignon' AND i.name = 'cognac'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Soupe_à_l''Oignon' AND i.name = 'thyme'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Soupe_à_l''Oignon' AND i.name = 'bay_leaf'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Blanquette_de_Veau' AND i.name = 'veal'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Blanquette_de_Veau' AND i.name = 'button_mushrooms'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Blanquette_de_Veau' AND i.name = 'pearl_onions'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Blanquette_de_Veau' AND i.name = 'cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Blanquette_de_Veau' AND i.name = 'egg_yolk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Blanquette_de_Veau' AND i.name = 'lemon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Blanquette_de_Veau' AND i.name = 'carrots'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Blanquette_de_Veau' AND i.name = 'bouquet_garni'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Salade_Niçoise' AND i.name = 'tuna'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Salade_Niçoise' AND i.name = 'green_beans'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Salade_Niçoise' AND i.name = 'potato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Salade_Niçoise' AND i.name = 'cherry_tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Salade_Niçoise' AND i.name = 'black_olives'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Salade_Niçoise' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Salade_Niçoise' AND i.name = 'anchovy'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Salade_Niçoise' AND i.name = 'dijon_vinaigrette'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pot-au-Feu' AND i.name = 'beef_brisket'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pot-au-Feu' AND i.name = 'bone_marrow'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pot-au-Feu' AND i.name = 'carrot'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pot-au-Feu' AND i.name = 'leek'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pot-au-Feu' AND i.name = 'turnip'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pot-au-Feu' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pot-au-Feu' AND i.name = 'celery'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pot-au-Feu' AND i.name = 'bouquet_garni'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sole_Meunière' AND i.name = 'sole_fillet'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sole_Meunière' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sole_Meunière' AND i.name = 'lemon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sole_Meunière' AND i.name = 'parsley'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sole_Meunière' AND i.name = 'flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sole_Meunière' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sole_Meunière' AND i.name = 'black_pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sole_Meunière' AND i.name = 'capers'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gratin_Dauphinois' AND i.name = 'potato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gratin_Dauphinois' AND i.name = 'heavy_cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gratin_Dauphinois' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gratin_Dauphinois' AND i.name = 'gruyere'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gratin_Dauphinois' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gratin_Dauphinois' AND i.name = 'nutmeg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gratin_Dauphinois' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gratin_Dauphinois' AND i.name = 'thyme'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Crêpes_Suzette' AND i.name = 'crêpe_batter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Crêpes_Suzette' AND i.name = 'orange_juice'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Crêpes_Suzette' AND i.name = 'orange_zest'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Crêpes_Suzette' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Crêpes_Suzette' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Crêpes_Suzette' AND i.name = 'grand_marnier'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Crêpes_Suzette' AND i.name = 'vanilla'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Crêpes_Suzette' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cassoulet' AND i.name = 'white_beans'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cassoulet' AND i.name = 'duck_confit'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cassoulet' AND i.name = 'pork_sausage'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cassoulet' AND i.name = 'pork_belly'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cassoulet' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cassoulet' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cassoulet' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Cassoulet' AND i.name = 'breadcrumbs'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Steak_Tartare' AND i.name = 'beef_tenderloin'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Steak_Tartare' AND i.name = 'egg_yolk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Steak_Tartare' AND i.name = 'capers'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Steak_Tartare' AND i.name = 'cornichon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Steak_Tartare' AND i.name = 'dijon_mustard'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Steak_Tartare' AND i.name = 'shallot'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Steak_Tartare' AND i.name = 'parsley'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Steak_Tartare' AND i.name = 'worcestershire'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Île_Flottante' AND i.name = 'egg_whites'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Île_Flottante' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Île_Flottante' AND i.name = 'crème_anglaise'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Île_Flottante' AND i.name = 'vanilla'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Île_Flottante' AND i.name = 'caramel'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Île_Flottante' AND i.name = 'almond'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Île_Flottante' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Île_Flottante' AND i.name = 'milk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Vichyssoise' AND i.name = 'leek'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Vichyssoise' AND i.name = 'potato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Vichyssoise' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Vichyssoise' AND i.name = 'heavy_cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Vichyssoise' AND i.name = 'chicken_broth'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Vichyssoise' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Vichyssoise' AND i.name = 'chives'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Vichyssoise' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mousse_au_Chocolat' AND i.name = 'dark_chocolate'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mousse_au_Chocolat' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mousse_au_Chocolat' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mousse_au_Chocolat' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mousse_au_Chocolat' AND i.name = 'vanilla'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mousse_au_Chocolat' AND i.name = 'cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mousse_au_Chocolat' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mousse_au_Chocolat' AND i.name = 'espresso'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Confit_Byaldi' AND i.name = 'zucchini'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Confit_Byaldi' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Confit_Byaldi' AND i.name = 'yellow_squash'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Confit_Byaldi' AND i.name = 'red_pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Confit_Byaldi' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Confit_Byaldi' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Confit_Byaldi' AND i.name = 'thyme'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Confit_Byaldi' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tarte_aux_Fraises' AND i.name = 'pastry_shell'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tarte_aux_Fraises' AND i.name = 'pastry_cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tarte_aux_Fraises' AND i.name = 'strawberry'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tarte_aux_Fraises' AND i.name = 'apricot_glaze'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tarte_aux_Fraises' AND i.name = 'vanilla'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tarte_aux_Fraises' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tarte_aux_Fraises' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tarte_aux_Fraises' AND i.name = 'flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gougères' AND i.name = 'choux_pastry'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gougères' AND i.name = 'gruyere'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gougères' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gougères' AND i.name = 'flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gougères' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gougères' AND i.name = 'milk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gougères' AND i.name = 'nutmeg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gougères' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sauerbraten' AND i.name = 'beef_roast'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sauerbraten' AND i.name = 'red_wine_vinegar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sauerbraten' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sauerbraten' AND i.name = 'carrot'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sauerbraten' AND i.name = 'celery'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sauerbraten' AND i.name = 'bay_leaf'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sauerbraten' AND i.name = 'cloves'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sauerbraten' AND i.name = 'gingersnap'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Schnitzel' AND i.name = 'pork_loin'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Schnitzel' AND i.name = 'breadcrumbs'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Schnitzel' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Schnitzel' AND i.name = 'flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Schnitzel' AND i.name = 'lemon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Schnitzel' AND i.name = 'clarified_butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Schnitzel' AND i.name = 'parsley'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Schnitzel' AND i.name = 'capers'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bratwurst' AND i.name = 'pork_sausage'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bratwurst' AND i.name = 'beer'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bratwurst' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bratwurst' AND i.name = 'mustard'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bratwurst' AND i.name = 'sauerkraut'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bratwurst' AND i.name = 'bread_roll'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bratwurst' AND i.name = 'caraway'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bratwurst' AND i.name = 'black_pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pretzels' AND i.name = 'bread_flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pretzels' AND i.name = 'yeast'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pretzels' AND i.name = 'baking_soda'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pretzels' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pretzels' AND i.name = 'coarse_salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pretzels' AND i.name = 'water'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pretzels' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pretzels' AND i.name = 'sesame'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Käsespätzle' AND i.name = 'spätzle'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Käsespätzle' AND i.name = 'emmental'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Käsespätzle' AND i.name = 'caramelized_onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Käsespätzle' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Käsespätzle' AND i.name = 'cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Käsespätzle' AND i.name = 'chives'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Käsespätzle' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Käsespätzle' AND i.name = 'pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sauerkraut' AND i.name = 'cabbage'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sauerkraut' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sauerkraut' AND i.name = 'caraway'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sauerkraut' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sauerkraut' AND i.name = 'apple'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sauerkraut' AND i.name = 'juniper_berry'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sauerkraut' AND i.name = 'white_wine'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Sauerkraut' AND i.name = 'bay_leaf'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rouladen' AND i.name = 'beef'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rouladen' AND i.name = 'bacon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rouladen' AND i.name = 'mustard'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rouladen' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rouladen' AND i.name = 'pickle'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rouladen' AND i.name = 'red_wine'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rouladen' AND i.name = 'broth'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rouladen' AND i.name = 'tomato_paste'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kartoffelsalat' AND i.name = 'potato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kartoffelsalat' AND i.name = 'bacon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kartoffelsalat' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kartoffelsalat' AND i.name = 'vinegar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kartoffelsalat' AND i.name = 'mustard'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kartoffelsalat' AND i.name = 'broth'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kartoffelsalat' AND i.name = 'parsley'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kartoffelsalat' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Schwarzwälder_Kirschtorte' AND i.name = 'chocolate_sponge'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Schwarzwälder_Kirschtorte' AND i.name = 'whipped_cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Schwarzwälder_Kirschtorte' AND i.name = 'cherry'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Schwarzwälder_Kirschtorte' AND i.name = 'kirschwasser'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Schwarzwälder_Kirschtorte' AND i.name = 'chocolate_shavings'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Schwarzwälder_Kirschtorte' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Schwarzwälder_Kirschtorte' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Schwarzwälder_Kirschtorte' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Lebkuchen' AND i.name = 'honey'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Lebkuchen' AND i.name = 'flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Lebkuchen' AND i.name = 'spices'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Lebkuchen' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Lebkuchen' AND i.name = 'baking_soda'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Lebkuchen' AND i.name = 'almonds'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Lebkuchen' AND i.name = 'candied_peel'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Lebkuchen' AND i.name = 'sugar_glaze'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Maultaschen' AND i.name = 'pasta_dough'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Maultaschen' AND i.name = 'pork'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Maultaschen' AND i.name = 'spinach'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Maultaschen' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Maultaschen' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Maultaschen' AND i.name = 'breadcrumbs'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Maultaschen' AND i.name = 'marjoram'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Maultaschen' AND i.name = 'broth'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Flammkuchen' AND i.name = 'thin_dough'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Flammkuchen' AND i.name = 'crème_fraîche'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Flammkuchen' AND i.name = 'lardons'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Flammkuchen' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Flammkuchen' AND i.name = 'emmental'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Flammkuchen' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Flammkuchen' AND i.name = 'pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Flammkuchen' AND i.name = 'nutmeg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Zwiebelkuchen' AND i.name = 'shortcrust_pastry'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Zwiebelkuchen' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Zwiebelkuchen' AND i.name = 'bacon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Zwiebelkuchen' AND i.name = 'sour_cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Zwiebelkuchen' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Zwiebelkuchen' AND i.name = 'caraway'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Zwiebelkuchen' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Zwiebelkuchen' AND i.name = 'pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Reibekuchen' AND i.name = 'potato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Reibekuchen' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Reibekuchen' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Reibekuchen' AND i.name = 'flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Reibekuchen' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Reibekuchen' AND i.name = 'apple_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Reibekuchen' AND i.name = 'sour_cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Reibekuchen' AND i.name = 'oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Grünkohl' AND i.name = 'kale'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Grünkohl' AND i.name = 'smoked_pork'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Grünkohl' AND i.name = 'pinkel_sausage'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Grünkohl' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Grünkohl' AND i.name = 'lard'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Grünkohl' AND i.name = 'mustard'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Grünkohl' AND i.name = 'oatmeal'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Grünkohl' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Eisbein' AND i.name = 'pork_knuckle'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Eisbein' AND i.name = 'sauerkraut'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Eisbein' AND i.name = 'potato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Eisbein' AND i.name = 'caraway'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Eisbein' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Eisbein' AND i.name = 'bay_leaf'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Eisbein' AND i.name = 'mustard'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Eisbein' AND i.name = 'broth'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Himmel_und_Erde' AND i.name = 'potato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Himmel_und_Erde' AND i.name = 'apple'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Himmel_und_Erde' AND i.name = 'black_pudding'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Himmel_und_Erde' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Himmel_und_Erde' AND i.name = 'lard'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Himmel_und_Erde' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Himmel_und_Erde' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Himmel_und_Erde' AND i.name = 'vinegar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Linsensuppe' AND i.name = 'lentils'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Linsensuppe' AND i.name = 'potato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Linsensuppe' AND i.name = 'carrot'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Linsensuppe' AND i.name = 'celery'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Linsensuppe' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Linsensuppe' AND i.name = 'bacon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Linsensuppe' AND i.name = 'vinegar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Linsensuppe' AND i.name = 'marjoram'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Apfelstrudel' AND i.name = 'strudel_dough'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Apfelstrudel' AND i.name = 'apple'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Apfelstrudel' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Apfelstrudel' AND i.name = 'cinnamon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Apfelstrudel' AND i.name = 'raisins'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Apfelstrudel' AND i.name = 'breadcrumbs'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Apfelstrudel' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Apfelstrudel' AND i.name = 'vanilla_cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bienenstich' AND i.name = 'yeast_dough'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bienenstich' AND i.name = 'honey_almond_topping'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bienenstich' AND i.name = 'vanilla_cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bienenstich' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bienenstich' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bienenstich' AND i.name = 'cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bienenstich' AND i.name = 'almonds'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bienenstich' AND i.name = 'milk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pfefferpotthast' AND i.name = 'beef'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pfefferpotthast' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pfefferpotthast' AND i.name = 'capers'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pfefferpotthast' AND i.name = 'lemon_zest'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pfefferpotthast' AND i.name = 'gingerbread'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pfefferpotthast' AND i.name = 'red_wine'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pfefferpotthast' AND i.name = 'broth'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pfefferpotthast' AND i.name = 'pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Königsberger_Klopse' AND i.name = 'ground_veal'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Königsberger_Klopse' AND i.name = 'anchovy'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Königsberger_Klopse' AND i.name = 'capers'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Königsberger_Klopse' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Königsberger_Klopse' AND i.name = 'cream_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Königsberger_Klopse' AND i.name = 'lemon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Königsberger_Klopse' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Königsberger_Klopse' AND i.name = 'breadcrumbs'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Labskaus' AND i.name = 'corned_beef'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Labskaus' AND i.name = 'potato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Labskaus' AND i.name = 'beetroot'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Labskaus' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Labskaus' AND i.name = 'pickled_herring'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Labskaus' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Labskaus' AND i.name = 'pickle'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Labskaus' AND i.name = 'lard'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Streuselkuchen' AND i.name = 'yeast_dough'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Streuselkuchen' AND i.name = 'streusel_topping'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Streuselkuchen' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Streuselkuchen' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Streuselkuchen' AND i.name = 'flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Streuselkuchen' AND i.name = 'vanilla'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Streuselkuchen' AND i.name = 'cinnamon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Streuselkuchen' AND i.name = 'cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rollmops' AND i.name = 'pickled_herring'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rollmops' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rollmops' AND i.name = 'pickle'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rollmops' AND i.name = 'mustard'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rollmops' AND i.name = 'vinegar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rollmops' AND i.name = 'bay_leaf'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rollmops' AND i.name = 'peppercorn'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Rollmops' AND i.name = 'carrot'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Thai' AND i.name = 'rice_noodles'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Thai' AND i.name = 'shrimp'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Thai' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Thai' AND i.name = 'bean_sprouts'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Thai' AND i.name = 'roasted_peanuts'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Thai' AND i.name = 'fish_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Thai' AND i.name = 'tamarind_paste'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Thai' AND i.name = 'lime'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Green_Curry' AND i.name = 'chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Green_Curry' AND i.name = 'green_curry_paste'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Green_Curry' AND i.name = 'coconut_milk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Green_Curry' AND i.name = 'bamboo_shoots'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Green_Curry' AND i.name = 'thai_basil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Green_Curry' AND i.name = 'fish_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Green_Curry' AND i.name = 'lime_leaves'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Green_Curry' AND i.name = 'eggplant'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tom_Yum_Goong' AND i.name = 'shrimp'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tom_Yum_Goong' AND i.name = 'lemongrass'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tom_Yum_Goong' AND i.name = 'galangal'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tom_Yum_Goong' AND i.name = 'kaffir_lime_leaves'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tom_Yum_Goong' AND i.name = 'straw_mushrooms'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tom_Yum_Goong' AND i.name = 'fish_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tom_Yum_Goong' AND i.name = 'lime'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tom_Yum_Goong' AND i.name = 'bird_eye_chili'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Som_Tum' AND i.name = 'green_papaya'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Som_Tum' AND i.name = 'cherry_tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Som_Tum' AND i.name = 'roasted_peanuts'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Som_Tum' AND i.name = 'lime'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Som_Tum' AND i.name = 'fish_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Som_Tum' AND i.name = 'dried_shrimp'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Som_Tum' AND i.name = 'palm_sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Som_Tum' AND i.name = 'bird_eye_chili'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Massaman_Curry' AND i.name = 'beef'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Massaman_Curry' AND i.name = 'potato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Massaman_Curry' AND i.name = 'roasted_peanuts'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Massaman_Curry' AND i.name = 'coconut_milk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Massaman_Curry' AND i.name = 'massaman_paste'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Massaman_Curry' AND i.name = 'pearl_onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Massaman_Curry' AND i.name = 'cinnamon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Massaman_Curry' AND i.name = 'tamarind'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Pad' AND i.name = 'jasmine_rice'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Pad' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Pad' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Pad' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Pad' AND i.name = 'soy_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Pad' AND i.name = 'fish_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Pad' AND i.name = 'spring_onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Pad' AND i.name = 'white_pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Larb_Moo' AND i.name = 'ground_pork'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Larb_Moo' AND i.name = 'lime'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Larb_Moo' AND i.name = 'fish_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Larb_Moo' AND i.name = 'fresh_mint'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Larb_Moo' AND i.name = 'cilantro'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Larb_Moo' AND i.name = 'bird_eye_chili'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Larb_Moo' AND i.name = 'toasted_rice_powder'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Larb_Moo' AND i.name = 'shallot'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_See_Ew' AND i.name = 'wide_rice_noodles'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_See_Ew' AND i.name = 'chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_See_Ew' AND i.name = 'chinese_broccoli'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_See_Ew' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_See_Ew' AND i.name = 'dark_soy_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_See_Ew' AND i.name = 'oyster_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_See_Ew' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_See_Ew' AND i.name = 'oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mango_Sticky_Rice' AND i.name = 'glutinous_rice'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mango_Sticky_Rice' AND i.name = 'ripe_mango'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mango_Sticky_Rice' AND i.name = 'coconut_milk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mango_Sticky_Rice' AND i.name = 'palm_sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mango_Sticky_Rice' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mango_Sticky_Rice' AND i.name = 'sesame'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mango_Sticky_Rice' AND i.name = 'pandan_leaf'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Mango_Sticky_Rice' AND i.name = 'cream'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tom_Kha_Gai' AND i.name = 'chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tom_Kha_Gai' AND i.name = 'coconut_milk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tom_Kha_Gai' AND i.name = 'lemongrass'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tom_Kha_Gai' AND i.name = 'galangal'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tom_Kha_Gai' AND i.name = 'oyster_mushroom'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tom_Kha_Gai' AND i.name = 'fish_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tom_Kha_Gai' AND i.name = 'lime'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tom_Kha_Gai' AND i.name = 'kaffir_lime_leaves'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Krapow_Moo' AND i.name = 'ground_pork'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Krapow_Moo' AND i.name = 'holy_basil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Krapow_Moo' AND i.name = 'bird_eye_chili'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Krapow_Moo' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Krapow_Moo' AND i.name = 'oyster_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Krapow_Moo' AND i.name = 'fish_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Krapow_Moo' AND i.name = 'soy_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Krapow_Moo' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Daeng' AND i.name = 'chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Daeng' AND i.name = 'red_curry_paste'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Daeng' AND i.name = 'coconut_milk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Daeng' AND i.name = 'bamboo_shoots'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Daeng' AND i.name = 'thai_basil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Daeng' AND i.name = 'fish_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Daeng' AND i.name = 'palm_sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Daeng' AND i.name = 'lime_leaves'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Soi' AND i.name = 'egg_noodles'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Soi' AND i.name = 'chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Soi' AND i.name = 'coconut_milk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Soi' AND i.name = 'khao_soi_paste'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Soi' AND i.name = 'shallot'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Soi' AND i.name = 'pickled_mustard'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Soi' AND i.name = 'lime'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Soi' AND i.name = 'crispy_noodles'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Satay' AND i.name = 'chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Satay' AND i.name = 'peanut_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Satay' AND i.name = 'lemongrass'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Satay' AND i.name = 'turmeric'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Satay' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Satay' AND i.name = 'coconut_milk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Satay' AND i.name = 'coriander'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Satay' AND i.name = 'soy_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Woon_Sen' AND i.name = 'glass_noodles'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Woon_Sen' AND i.name = 'shrimp'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Woon_Sen' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Woon_Sen' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Woon_Sen' AND i.name = 'celery'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Woon_Sen' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Woon_Sen' AND i.name = 'soy_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pad_Woon_Sen' AND i.name = 'oyster_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gai_Yang' AND i.name = 'chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gai_Yang' AND i.name = 'lemongrass'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gai_Yang' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gai_Yang' AND i.name = 'coriander_root'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gai_Yang' AND i.name = 'fish_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gai_Yang' AND i.name = 'palm_sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gai_Yang' AND i.name = 'black_pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gai_Yang' AND i.name = 'turmeric'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Yam_Woon_Sen' AND i.name = 'glass_noodles'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Yam_Woon_Sen' AND i.name = 'shrimp'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Yam_Woon_Sen' AND i.name = 'pork'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Yam_Woon_Sen' AND i.name = 'lime'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Yam_Woon_Sen' AND i.name = 'fish_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Yam_Woon_Sen' AND i.name = 'bird_eye_chili'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Yam_Woon_Sen' AND i.name = 'celery'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Yam_Woon_Sen' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Keow_Wan' AND i.name = 'chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Keow_Wan' AND i.name = 'green_curry_paste'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Keow_Wan' AND i.name = 'coconut_milk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Keow_Wan' AND i.name = 'pea_eggplant'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Keow_Wan' AND i.name = 'thai_basil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Keow_Wan' AND i.name = 'fish_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Keow_Wan' AND i.name = 'palm_sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Keow_Wan' AND i.name = 'bamboo_shoots'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hoy_Tod' AND i.name = 'oyster'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hoy_Tod' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hoy_Tod' AND i.name = 'bean_sprouts'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hoy_Tod' AND i.name = 'rice_flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hoy_Tod' AND i.name = 'tapioca_flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hoy_Tod' AND i.name = 'sriracha'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hoy_Tod' AND i.name = 'oyster_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hoy_Tod' AND i.name = 'oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khanom_Krok' AND i.name = 'coconut_milk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khanom_Krok' AND i.name = 'rice_flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khanom_Krok' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khanom_Krok' AND i.name = 'pandan'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khanom_Krok' AND i.name = 'green_onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khanom_Krok' AND i.name = 'corn'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khanom_Krok' AND i.name = 'dried_shrimp'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khanom_Krok' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Nam_Tok_Moo' AND i.name = 'grilled_pork'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Nam_Tok_Moo' AND i.name = 'lime'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Nam_Tok_Moo' AND i.name = 'fish_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Nam_Tok_Moo' AND i.name = 'chili_flakes'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Nam_Tok_Moo' AND i.name = 'toasted_rice_powder'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Nam_Tok_Moo' AND i.name = 'mint'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Nam_Tok_Moo' AND i.name = 'shallot'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Nam_Tok_Moo' AND i.name = 'green_onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Som' AND i.name = 'shrimp'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Som' AND i.name = 'white_turmeric'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Som' AND i.name = 'tamarind'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Som' AND i.name = 'fish_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Som' AND i.name = 'palm_sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Som' AND i.name = 'vegetables'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Som' AND i.name = 'chili'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gaeng_Som' AND i.name = 'shrimp_paste'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Tom' AND i.name = 'jasmine_rice'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Tom' AND i.name = 'chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Tom' AND i.name = 'ginger'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Tom' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Tom' AND i.name = 'fish_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Tom' AND i.name = 'celery'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Tom' AND i.name = 'sesame_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Khao_Tom' AND i.name = 'white_pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tod_Mun_Pla' AND i.name = 'fish'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tod_Mun_Pla' AND i.name = 'red_curry_paste'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tod_Mun_Pla' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tod_Mun_Pla' AND i.name = 'kaffir_lime_leaves'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tod_Mun_Pla' AND i.name = 'green_bean'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tod_Mun_Pla' AND i.name = 'sweet_chili_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tod_Mun_Pla' AND i.name = 'cucumber'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tod_Mun_Pla' AND i.name = 'coriander'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bua_Loy' AND i.name = 'glutinous_rice_flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bua_Loy' AND i.name = 'coconut_milk'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bua_Loy' AND i.name = 'pandan'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bua_Loy' AND i.name = 'taro'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bua_Loy' AND i.name = 'sweet_potato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bua_Loy' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bua_Loy' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Bua_Loy' AND i.name = 'sesame'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Moussaka' AND i.name = 'eggplant'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Moussaka' AND i.name = 'ground_lamb'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Moussaka' AND i.name = 'bechamel'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Moussaka' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Moussaka' AND i.name = 'cinnamon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Moussaka' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Moussaka' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Moussaka' AND i.name = 'parmesan'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hummus' AND i.name = 'chickpeas'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hummus' AND i.name = 'tahini'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hummus' AND i.name = 'lemon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hummus' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hummus' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hummus' AND i.name = 'cumin'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hummus' AND i.name = 'paprika'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Hummus' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Falafel' AND i.name = 'dried_chickpeas'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Falafel' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Falafel' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Falafel' AND i.name = 'fresh_parsley'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Falafel' AND i.name = 'cumin'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Falafel' AND i.name = 'coriander'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Falafel' AND i.name = 'flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Falafel' AND i.name = 'sesame'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tabbouleh' AND i.name = 'fine_bulgur'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tabbouleh' AND i.name = 'flat_leaf_parsley'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tabbouleh' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tabbouleh' AND i.name = 'cucumber'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tabbouleh' AND i.name = 'lemon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tabbouleh' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tabbouleh' AND i.name = 'mint'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tabbouleh' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Paella' AND i.name = 'bomba_rice'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Paella' AND i.name = 'saffron'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Paella' AND i.name = 'chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Paella' AND i.name = 'prawn'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Paella' AND i.name = 'mussel'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Paella' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Paella' AND i.name = 'smoked_paprika'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Paella' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Shawarma' AND i.name = 'chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Shawarma' AND i.name = 'garlic_sauce'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Shawarma' AND i.name = 'pita'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Shawarma' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Shawarma' AND i.name = 'pickle'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Shawarma' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Shawarma' AND i.name = 'sumac'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Shawarma' AND i.name = 'tahini'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Spanakopita' AND i.name = 'spinach'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Spanakopita' AND i.name = 'feta'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Spanakopita' AND i.name = 'phyllo_dough'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Spanakopita' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Spanakopita' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Spanakopita' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Spanakopita' AND i.name = 'dill'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Spanakopita' AND i.name = 'nutmeg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tzatziki' AND i.name = 'greek_yogurt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tzatziki' AND i.name = 'cucumber'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tzatziki' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tzatziki' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tzatziki' AND i.name = 'fresh_dill'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tzatziki' AND i.name = 'lemon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tzatziki' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Tzatziki' AND i.name = 'mint'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Baklava' AND i.name = 'phyllo_dough'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Baklava' AND i.name = 'walnuts'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Baklava' AND i.name = 'pistachios'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Baklava' AND i.name = 'honey'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Baklava' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Baklava' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Baklava' AND i.name = 'lemon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Baklava' AND i.name = 'cinnamon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Souvlaki' AND i.name = 'pork'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Souvlaki' AND i.name = 'lemon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Souvlaki' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Souvlaki' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Souvlaki' AND i.name = 'dried_oregano'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Souvlaki' AND i.name = 'pita'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Souvlaki' AND i.name = 'tzatziki'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Souvlaki' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kibbeh' AND i.name = 'ground_lamb'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kibbeh' AND i.name = 'bulgur'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kibbeh' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kibbeh' AND i.name = 'pine_nuts'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kibbeh' AND i.name = 'cinnamon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kibbeh' AND i.name = 'allspice'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kibbeh' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kibbeh' AND i.name = 'mint'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Shakshuka' AND i.name = 'eggs'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Shakshuka' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Shakshuka' AND i.name = 'red_bell_pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Shakshuka' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Shakshuka' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Shakshuka' AND i.name = 'cumin'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Shakshuka' AND i.name = 'paprika'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Shakshuka' AND i.name = 'feta'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Baba_Ganoush' AND i.name = 'eggplant'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Baba_Ganoush' AND i.name = 'tahini'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Baba_Ganoush' AND i.name = 'lemon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Baba_Ganoush' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Baba_Ganoush' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Baba_Ganoush' AND i.name = 'cumin'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Baba_Ganoush' AND i.name = 'flat_leaf_parsley'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Baba_Ganoush' AND i.name = 'pomegranate'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Fattoush' AND i.name = 'romaine'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Fattoush' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Fattoush' AND i.name = 'cucumber'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Fattoush' AND i.name = 'radish'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Fattoush' AND i.name = 'pita_chips'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Fattoush' AND i.name = 'sumac'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Fattoush' AND i.name = 'lemon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Fattoush' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Borek' AND i.name = 'phyllo_dough'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Borek' AND i.name = 'feta'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Borek' AND i.name = 'spinach'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Borek' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Borek' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Borek' AND i.name = 'sesame'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Borek' AND i.name = 'nigella_seeds'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Borek' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dolmades' AND i.name = 'grape_leaves'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dolmades' AND i.name = 'rice'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dolmades' AND i.name = 'ground_lamb'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dolmades' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dolmades' AND i.name = 'lemon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dolmades' AND i.name = 'dill'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dolmades' AND i.name = 'mint'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Dolmades' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Imam_Bayildi' AND i.name = 'eggplant'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Imam_Bayildi' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Imam_Bayildi' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Imam_Bayildi' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Imam_Bayildi' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Imam_Bayildi' AND i.name = 'flat_leaf_parsley'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Imam_Bayildi' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Imam_Bayildi' AND i.name = 'lemon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kleftiko' AND i.name = 'lamb_shoulder'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kleftiko' AND i.name = 'lemon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kleftiko' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kleftiko' AND i.name = 'dried_oregano'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kleftiko' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kleftiko' AND i.name = 'potato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kleftiko' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Kleftiko' AND i.name = 'bay_leaf'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gazpacho' AND i.name = 'ripe_tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gazpacho' AND i.name = 'cucumber'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gazpacho' AND i.name = 'red_bell_pepper'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gazpacho' AND i.name = 'red_onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gazpacho' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gazpacho' AND i.name = 'sherry_vinegar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gazpacho' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Gazpacho' AND i.name = 'bread'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Labneh' AND i.name = 'strained_yogurt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Labneh' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Labneh' AND i.name = 'zaatar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Labneh' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Labneh' AND i.name = 'fresh_mint'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Labneh' AND i.name = 'lemon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Labneh' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Labneh' AND i.name = 'cucumber'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Couscous_Royal' AND i.name = 'semolina'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Couscous_Royal' AND i.name = 'lamb'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Couscous_Royal' AND i.name = 'merguez'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Couscous_Royal' AND i.name = 'chickpeas'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Couscous_Royal' AND i.name = 'root_vegetables'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Couscous_Royal' AND i.name = 'harissa'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Couscous_Royal' AND i.name = 'ras_el_hanout'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Couscous_Royal' AND i.name = 'butter'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pastilla' AND i.name = 'chicken'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pastilla' AND i.name = 'almond'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pastilla' AND i.name = 'egg'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pastilla' AND i.name = 'phyllo_dough'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pastilla' AND i.name = 'cinnamon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pastilla' AND i.name = 'sugar'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pastilla' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Pastilla' AND i.name = 'saffron'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Fatayer' AND i.name = 'bread_dough'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Fatayer' AND i.name = 'spinach'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Fatayer' AND i.name = 'sumac'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Fatayer' AND i.name = 'onion'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Fatayer' AND i.name = 'lemon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Fatayer' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Fatayer' AND i.name = 'pine_nuts'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Fatayer' AND i.name = 'salt'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Grilled_Octopus' AND i.name = 'octopus'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Grilled_Octopus' AND i.name = 'lemon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Grilled_Octopus' AND i.name = 'olive_oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Grilled_Octopus' AND i.name = 'garlic'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Grilled_Octopus' AND i.name = 'oregano'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Grilled_Octopus' AND i.name = 'capers'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Grilled_Octopus' AND i.name = 'tomato'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Grilled_Octopus' AND i.name = 'parsley'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Loukoumades' AND i.name = 'flour'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Loukoumades' AND i.name = 'yeast'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Loukoumades' AND i.name = 'honey'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Loukoumades' AND i.name = 'cinnamon'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Loukoumades' AND i.name = 'sesame'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Loukoumades' AND i.name = 'walnut'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Loukoumades' AND i.name = 'oil'
UNION ALL
    SELECT r.id, i.id FROM recipes r, ingredients i WHERE r.dish = 'Loukoumades' AND i.name = 'sugar'
ON CONFLICT DO NOTHING;