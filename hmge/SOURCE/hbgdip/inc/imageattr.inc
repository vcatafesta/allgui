
typedef GpStatus (WINGDIPAPI * GdipCreateImageAttributes_ptr)(GpImageAttributes **imageattr);
//typedef GpStatus (WINGDIPAPI * GdipCloneImageAttributes_ptr)(GDIPCONST GpImageAttributes *imageattr, GpImageAttributes **cloneImageattr);
typedef GpStatus (WINGDIPAPI * GdipDisposeImageAttributes_ptr)(GpImageAttributes *imageattr);
//typedef GpStatus (WINGDIPAPI * GdipSetImageAttributesToIdentity_ptr)(GpImageAttributes *imageattr, ColorAdjustType type);
//typedef GpStatus (WINGDIPAPI * GdipResetImageAttributes_ptr)(GpImageAttributes *imageattr, ColorAdjustType type);
//typedef GpStatus (WINGDIPAPI * GdipSetImageAttributesColorMatrix_ptr)(GpImageAttributes *imageattr, ColorAdjustType type, BOOL enableFlag, GDIPCONST ColorMatrix* colorMatrix, GDIPCONST ColorMatrix* grayMatrix, ColorMatrixFlags flags);
//typedef GpStatus (WINGDIPAPI * GdipSetImageAttributesThreshold_ptr)(GpImageAttributes *imageattr, ColorAdjustType type, BOOL enableFlag, REAL threshold);
//typedef GpStatus (WINGDIPAPI * GdipSetImageAttributesGamma_ptr)(GpImageAttributes *imageattr, ColorAdjustType type, BOOL enableFlag, REAL gamma);
//typedef GpStatus (WINGDIPAPI * GdipSetImageAttributesNoOp_ptr)(GpImageAttributes *imageattr, ColorAdjustType type, BOOL enableFlag);
//typedef GpStatus (WINGDIPAPI * GdipSetImageAttributesColorKeys_ptr)(GpImageAttributes *imageattr, ColorAdjustType type, BOOL enableFlag, ARGB colorLow, ARGB colorHigh);
//typedef GpStatus (WINGDIPAPI * GdipSetImageAttributesOutputChannel_ptr)(GpImageAttributes *imageattr, ColorAdjustType type, BOOL enableFlag, ColorChannelFlags channelFlags);
//typedef GpStatus (WINGDIPAPI * GdipSetImageAttributesOutputChannelColorProfile_ptr)(GpImageAttributes *imageattr, ColorAdjustType type, BOOL enableFlag, GDIPCONST WCHAR *colorProfileFilename);
//typedef GpStatus (WINGDIPAPI * GdipSetImageAttributesRemapTable_ptr)(GpImageAttributes *imageattr, ColorAdjustType type, BOOL enableFlag, UINT mapSize, GDIPCONST ColorMap *map);
//typedef GpStatus (WINGDIPAPI * GdipSetImageAttributesWrapMode_ptr)(GpImageAttributes *imageAttr, WrapMode wrap, ARGB argb, BOOL clamp);
//typedef GpStatus (WINGDIPAPI * GdipSetImageAttributesICMMode_ptr)(GpImageAttributes *imageAttr, BOOL on);
//typedef GpStatus (WINGDIPAPI * GdipGetImageAttributesAdjustedPalette_ptr)(GpImageAttributes *imageAttr, ColorPalette * colorPalette, ColorAdjustType colorAdjustType);

DECLARE_FUNCPTR(GdipCreateImageAttributes);
//DECLARE_FUNCPTR(GdipCloneImageAttributes);
DECLARE_FUNCPTR(GdipDisposeImageAttributes);
//DECLARE_FUNCPTR(GdipSetImageAttributesToIdentity);
//DECLARE_FUNCPTR(GdipResetImageAttributes);
//DECLARE_FUNCPTR(GdipSetImageAttributesColorMatrix);
//DECLARE_FUNCPTR(GdipSetImageAttributesThreshold);
//DECLARE_FUNCPTR(GdipSetImageAttributesGamma);
//DECLARE_FUNCPTR(GdipSetImageAttributesNoOp);
//DECLARE_FUNCPTR(GdipSetImageAttributesColorKeys);
//DECLARE_FUNCPTR(GdipSetImageAttributesOutputChannel);
//DECLARE_FUNCPTR(GdipSetImageAttributesOutputChannelColorProfile);
//DECLARE_FUNCPTR(GdipSetImageAttributesRemapTable);
//DECLARE_FUNCPTR(GdipSetImageAttributesWrapMode);
//DECLARE_FUNCPTR(GdipSetImageAttributesICMMode);
//DECLARE_FUNCPTR(GdipGetImageAttributesAdjustedPalette);
