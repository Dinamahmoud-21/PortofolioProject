-- cleaning data in sql queries 
select * from ProtfoliProject.dbo.NashvilleHousing

-- standardize data format
select saledate, convert(date,saledate) as saledateconverted from ProtfoliProject.dbo.NashvilleHousing

alter table NashvilleHousing 
add saledateconverted date

update NashvilleHousing 
set saledateconverted=convert(date,saledate)

select saledate, saledateconverted from ProtfoliProject.dbo.NashvilleHousing

--popular property Address data
select a.propertyAddress, a.parcelid, b.propertyAddress, b.parcelid 
from nashvillehousing a
join nashvillehousing b
on a.parcelid=b.parcelid
and a.uniqueid<> b.uniqueid
where a.propertyAddress is null

update a
set a.propertyAddress=isnull(a.propertyAddress,b.propertyAddress)
from nashvillehousing a
join nashvillehousing b
on a.parcelid=b.parcelid
and a.uniqueid<> b.uniqueid
where a.propertyAddress is null


--breaking out address into individual column (address,city,state)
select propertyaddress from nashvillehousing

select 
SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1) as Address
,SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress)) as City
from nashvillehousing

alter table nashvillehousing add propertySplitedAddress nvarchar(255)
alter table nashvillehousing add propertySplitedCity nvarchar(255)

update nashvillehousing
set propertySplitedAddress=SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1)

update nashvillehousing
set propertySplitedCity=SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress))

select 
PARSENAME(REPLACE(owneraddress,',','.'),3)
,PARSENAME(REPLACE(owneraddress,',','.'),2)
,PARSENAME(REPLACE(owneraddress,',','.'),1)
from nashvillehousing

alter table nashvillehousing add ownerSplitedAddress nvarchar(255)
alter table nashvillehousing add ownerSplitedCity nvarchar(255)
alter table nashvillehousing add ownerSplitedState nvarchar(255)

update nashvillehousing
set ownerSplitedAddress=PARSENAME(REPLACE(owneraddress,',','.'),3)

update nashvillehousing
set ownerSplitedCity=PARSENAME(REPLACE(owneraddress,',','.'),2)

update nashvillehousing
set ownerSplitedState=PARSENAME(REPLACE(owneraddress,',','.'),1)

--change Y , N to Yes, No in "Sold as Vacant" field

select Distinct(SoldasVacant), count(SoldasVacant)
from nashvillehousing
group by SoldasVacant

select soldasvacant,
case when soldasvacant='Y' then 'Yes'
when soldasvacant='N' then 'No'
else soldasvacant
end
from nashvillehousing

update nashvillehousing
set soldasvacant=case when soldasvacant='Y' then 'Yes'
when soldasvacant='N' then 'No'
else soldasvacant
end

--remove duplicates
with row_num_cts as
(select *,ROW_NUMBER() over (partition by parcelid,propertyaddress
,saledate,saleprice,legalreference order by uniqueid) row_num
from nashvillehousing)

delete from row_num_cts
 where row_num>1

-- delete unused columns
select * from nashvillehousing

alter table nashvillehousing
drop column propertyaddress, owneraddress, taxdistrict,saledate

