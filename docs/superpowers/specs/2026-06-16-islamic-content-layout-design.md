# Islamic Content Screen - Compact Grid Layout Design

## Objective
Fix the excessive vertical/horizontal spacing between menu items (like "Asmaul Husna" and "Doa Harian") on the Islamic Content Screen, and ensure the UI feels harmonized and visually balanced across Light and Dark modes.

## Approach: Compact Grid
We will implement **Approach A (Compact Grid)**.

### Specific Layout Adjustments
1. **Grid Spacing**: 
   - `crossAxisSpacing` and `mainAxisSpacing` will be reduced from `12.0` to `10.0` to pull the cards closer together.
2. **Card Proportions**:
   - `mainAxisExtent` (fixed height of the cards) will be reduced significantly from `156.0` (and `170.0` on small screens) down to `130.0`. This prevents the cards from looking stretched or empty.
3. **Internal Padding**:
   - The padding inside `_ContentMenuCard` will be reduced from `16.0` to `14.0` so the text and icon fit perfectly within the newly compacted height.
4. **Typography**:
   - Title font size inside the card remains at `15`, but we will ensure line heights are tight.
   - Subtitle font size remains at `12` but will be clamped to 2 lines tightly.
5. **Icon Container**:
   - The decorative box behind the icon will be slightly reduced from `42x42` to `38x38` to save vertical space.

## Success Criteria
- The gap between menu items is visibly smaller and more cohesive.
- The cards do not feel "empty" or overly tall.
- The layout remains fully responsive (2 columns on mobile, 3 on tablets).
- Dark and light modes continue to look polished and harmonized.
