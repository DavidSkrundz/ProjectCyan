//
// ShopDataSource.cpp
// Implementation of the ShopDataSource, ShopDataGroup, ShopDataItem, and ShopDataCommon classes
//

#include "pch.h"

using namespace App2::Data;

using namespace Platform;
using namespace Platform::Collections;
using namespace concurrency;
using namespace Windows::ApplicationModel::Resources::Core;
using namespace Windows::Foundation;
using namespace Windows::Foundation::Collections;
using namespace Windows::UI::Xaml::Data;
using namespace Windows::UI::Xaml::Interop;
using namespace Windows::UI::Xaml::Media;
using namespace Windows::UI::Xaml::Media::Imaging;
using namespace Windows::Storage;
using namespace Windows::Data::Json;

//
// ShopDataItem
//

ShopDataItem::ShopDataItem(String^ uniqueId, String^ title, String^ subtitle, String^ imagePath, String^ description,
	String^ content) :
	_uniqueId(uniqueId),
	_title(title),
	_subtitle(subtitle),
	_description(description),
	_imagePath(imagePath),
	_content(content)
	{
	}

	String^ ShopDataItem::UniqueId::get()
	{
		return _uniqueId;
	}

	String^ ShopDataItem::Title::get()
	{
		return _title;
	}

	String^ ShopDataItem::Subtitle::get()
	{
		return _subtitle;
	}

	String^ ShopDataItem::Description::get()
	{
		return _description;
	}

	String^ ShopDataItem::Content::get()
	{
		return _content;
	}

	String^ ShopDataItem::ImagePath::get()
	{
		return _imagePath;
	}

	Windows::UI::Xaml::Data::ICustomProperty^ ShopDataItem::GetCustomProperty(Platform::String^ name)
	{
		return nullptr;
	}

	Windows::UI::Xaml::Data::ICustomProperty^ ShopDataItem::GetIndexedProperty(Platform::String^ name, Windows::UI::Xaml::Interop::TypeName type)
	{
		return nullptr;
	}

	Platform::String^ ShopDataItem::GetStringRepresentation()
	{
		return Title;
	}

	Windows::UI::Xaml::Interop::TypeName ShopDataItem::Type::get()
	{
		return this->GetType();
	}

	//
	// ShopDataGroup
	//

	ShopDataGroup::ShopDataGroup(String^ uniqueId, String^ title, String^ subtitle, String^ imagePath, String^ description) :
		_uniqueId(uniqueId),
		_title(title),
		_subtitle(subtitle),
		_description(description),
		_imagePath(imagePath),
		_items(ref new Vector<ShopDataItem^>())
		{
		}

		String^ ShopDataGroup::UniqueId::get()
		{
			return _uniqueId;
		}

		String^ ShopDataGroup::Title::get()
		{
			return _title;
		}

		String^ ShopDataGroup::Subtitle::get()
		{
			return _subtitle;
		}

		String^ ShopDataGroup::Description::get()
		{
			return _description;
		}

		IObservableVector<ShopDataItem^>^ ShopDataGroup::Items::get()
		{
			return _items;
		}

		String^ ShopDataGroup::ImagePath::get()
		{
			return _imagePath;
		}

		Windows::UI::Xaml::Data::ICustomProperty^ ShopDataGroup::GetCustomProperty(Platform::String^ name)
		{
			return nullptr;
		}

		Windows::UI::Xaml::Data::ICustomProperty^ ShopDataGroup::GetIndexedProperty(Platform::String^ name, Windows::UI::Xaml::Interop::TypeName type)
		{
			return nullptr;
		}

		Platform::String^ ShopDataGroup::GetStringRepresentation()
		{
			return Title;
		}

		Windows::UI::Xaml::Interop::TypeName ShopDataGroup::Type::get()
		{
			return this->GetType();
		}

		//
		// Pulls the location and type of the shops from the server to the data file
		//

		ShopDataSource::ShopDataSource()
		{
			_groups = ref new Vector<ShopDataGroup^>();

			Uri^ uri = ref new Uri("http://192.168.1.190/pull.php?lat=5&lon=5type=coffee");//ms-appx:///DataModel/SampleData.json  http://192.168.1.190/pull.php?lat=5&lon=5type=coffee
			create_task(StorageFile::GetFileFromApplicationUriAsync(uri))
				.then([](StorageFile^ storageFile)
			{
				return FileIO::ReadTextAsync(storageFile);
			})
				.then([this](String^ jsonText)
			{
				JsonObject^ jsonObject = JsonObject::Parse(jsonText);
				// OutputDebugString(((jsonObject->Stringify()->Data())));

				auto jsonVector = jsonObject->GetNamedArray("Devices")->GetView();

				for (const auto &jsonGroupValue : jsonVector){
					JsonObject^ groupObject = jsonGroupValue->GetObject();
					ShopDataGroup^ group = ref new ShopDataGroup(groupObject->GetNamedString("loc"),

					
				}
				// auto jsonVector = jsonObject->GetNamedArray("Groups")->GetView();

				/*for (const auto &jsonGroupValue : jsonVector)
				{
					JsonObject^ groupObject = jsonGroupValue->GetObject();
					ShopDataGroup^ group = ref new ShopDataGroup(groupObject->GetNamedString("UniqueId"),
						groupObject->GetNamedString("Title"),
						groupObject->GetNamedString("Subtitle"),
						groupObject->GetNamedString("ImagePath"),
						groupObject->GetNamedString("Description"));

					auto jsonItemVector = groupObject->GetNamedArray("Items")->GetView();
					for (const auto &jsonItemValue : jsonItemVector)
					{
						JsonObject^ itemObject = jsonItemValue->GetObject();

						ShopDataItem^ item = ref new ShopDataItem(itemObject->GetNamedString("UniqueId"),
							itemObject->GetNamedString("Title"),
							itemObject->GetNamedString("Subtitle"),
							itemObject->GetNamedString("ImagePath"),
							itemObject->GetNamedString("Description"),
							itemObject->GetNamedString("Content"));

						group->Items->Append(item);
					};

					_groups->Append(group);
				};*/
			})
				.then([this](task<void> t)
			{
				try
				{
					t.get();
				}
				catch (Platform::COMException^ e)
				{
					OutputDebugString(e->Message->Data());
					// TODO: If App can recover from exception,
					// remove throw; below and add recovery code.
					throw;
				}
				// Signal load completion event
				_loadCompletionEvent.set();
			});
		}

		IObservableVector<ShopDataGroup^>^ ShopDataSource::Groups::get()
		{
			return _groups;
		}

		ShopDataSource^ ShopDataSource::_shopDataSource = nullptr;

		task<void> ShopDataSource::Init()
		{
			if (_shopDataSource == nullptr)
			{
				_shopDataSource = ref new ShopDataSource();
			}
			return create_task(_shopDataSource->_loadCompletionEvent);
		}

		task<IIterable<ShopDataGroup^>^> ShopDataSource::GetGroups()
		{
			return Init()
				.then([]() -> IIterable<ShopDataGroup^> ^
			{
				return _shopDataSource->Groups;
			});
		}

		task<ShopDataGroup^> ShopDataSource::GetGroup(String^ uniqueId)
		{
			return Init()
				.then([uniqueId]() -> ShopDataGroup ^
			{
				// Simple linear search is acceptable for small data sets
				for (const auto& group : _shopDataSource->Groups)
				{
					if (group->UniqueId == uniqueId)
					{
						return group;
					}
				}
				return nullptr;
			});
		}

		task<ShopDataItem^> ShopDataSource::GetItem(String^ uniqueId)
		{
			return Init()
				.then([uniqueId]() -> ShopDataItem ^
			{
				// Simple linear search is acceptable for small data sets
				for (const auto& group : _shopDataSource->Groups)
				{
					for (const auto& item : group->Items)
					{
						if (item->UniqueId == uniqueId)
						{
							return item;
						}
					}
				}
				return nullptr;
			});
		}
