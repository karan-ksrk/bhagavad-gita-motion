// On-demand Play asset pack with chapter 2 media (D-139).
// Files in src/main/assets/ keep the paths listed in
// assets/content/media_manifest.json for assets with "pack": "chapter_02".
plugins {
    id("com.android.asset-pack")
}

assetPack {
    packName.set("chapter_02")
    dynamicDelivery {
        deliveryType.set("on-demand")
    }
}
