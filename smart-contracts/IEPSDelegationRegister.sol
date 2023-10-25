// SPDX-License-Identifier: CC0-1.0
// EPS Contracts v2.0.0
// www.eternalproxy.com

/**
 
@dev EPS Delegation Register - Interface

 */

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

/**
 *
 * @dev Implementation of the EPS proxy register interface.
 *
 */
interface IEPSDelegationRegister {
  // ======================================================
  // ENUMS and STRUCTS
  // ======================================================

  // Scope of a delegation: global, collection or token
  enum DelegationScope {
    globalScope,
    collectionScope,
    tokenScope
  }

  // The Class of a delegation: primary, secondary or rental
  enum DelegationClass {
    primary,
    secondary,
    rental
  }

  // The status of a delegation:
  enum DelegationStatus {
    live,
    pending
  }

  // Data output format for a report (used to output both hot and cold
  // delegation details)
  struct DelegationReport {
    address hot;
    address cold;
    DelegationScope scope;
    DelegationClass class;
    address collection;
    uint256 tokenId;
    uint48 startDate;
    uint48 endDate;
    bool validByDate;
    bool validBilaterally;
    bool validTokenOwnership;
    bool[78] usageTypesArray;
    bytes32 key;
    uint256 usageTypesInteger;
    bytes data;
    DelegationStatus status;
  }

  // Delegation record
  // 160
  //  48
  //  48
  // ===
  // 256
  // ===
  // 160
  //  32 (8 * 4)
  // ===
  // 192
  // ===
  // 256

  struct DelegationRecord {
    address hot;
    uint48 startDate;
    uint48 endDate;
    address cold;
    DelegationScope delegationScope;
    DelegationClass delegationClass;
    DelegationStatus delegationStatus;
    uint256 usageTypesInteger;
  }

  // If a delegation is for a collection, or has additional data, it will need to read the delegation metadata
  struct DelegationMetadata {
    address collection;
    uint256 tokenId;
    bytes data;
  }

  // Details of a hot wallet lock
  struct LockDetails {
    uint40 lockStart;
    uint40 lockEnd;
  }

  // Validity dates when checking a delegation
  struct ValidityDates {
    uint48 start;
    uint48 end;
  }

  // Delegation struct to hold details of a new delegation
  struct Delegation {
    address hot;
    address cold;
    DelegationStatus delegationStatus;
    DelegationScope delegationScope;
    DelegationClass delegationClass;
    address collection;
    uint256 tokenId;
    uint8[] usageTypesArray;
    uint48 startDate;
    uint48 endDate;
    bytes20 providerCode;
    bytes data;
  }

  // Addresses associated with a delegation check
  struct DelegationCheckAddresses {
    address hot;
    address cold;
    address targetCollection;
  }

  // Classes associated with a delegation check
  struct DelegationCheckClasses {
    bool secondary;
    bool rental;
    bool token;
    bool keyCheckNotRequired;
  }

  // User balance overrider
  struct UserBalanceOverride {
    bool isOverridden;
    uint240 balanceOverride;
  }

  // ======================================================
  // CUSTOM ERRORS
  // ======================================================

  error UsageTypeAlreadyDelegated(uint256 usageType);
  error CannotDeleteValidDelegation();
  error CannotDelegatedATokenTheColdDoesNotOwn();
  error IncorrectAdminLevel(uint256 requiredLevel);
  error OnlyParticipantOrAuthorisedSubDelegate();
  error HotAddressIsLockedAndCannotBeDelegatedTo();
  error InvalidDelegation();
  error ToMuchETHForPendingPayments(uint256 sent, uint256 required);
  error UnknownAmount();
  error InvalidERC20Payment();
  error IncorrectProxyRegisterFee();
  error UnrecognisedEPSAPIAmount();
  error CannotRevokeAllForRegisterAdminHierarchy();
  error SubDelegationCannotBeCombinedWithOtherUsages();
  error SubDelegationCannotBeAtTokenLevel();
  error EternalMustNotHaveDates();
  error TimeLimitedMustHaveDates();
  error CannotCombineGlobalScopeWithCollection();
  error InvalidBalance();

  // ======================================================
  // EVENTS
  // ======================================================

  event DelegationMade(bytes32 delegationKey);
  event DelegationRevoked(address hot, address cold, bytes32 delegationKey);
  event DelegationPaid(bytes32 delegationKey);
  event AllDelegationsRevokedForHot(address hot);
  event AllDelegationsRevokedForCold(address cold);
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev updateFee - The register fee is locked to USD5.00 worth of ETH.
   * Rather than including the cost of a payment feed lookup in every delegation,
   * we allow anyone to update the fee on the contract. This allows for a single
   * call to set the price as required. So when ETH rises in value this method
   * can be called by any user to reduce the ETH fee that is payable for a delegation.
   *
   * This method can be called once every 24 hours. This prevents it being spammed
   * in a denial of service style attack that forces updates to the price while
   * transactions are already in progress.
   */
  function updateFee(uint256 registerFee_) external;

  /**
   * @dev decimals -  Returns the decimals of the token.
   *
   * @return uint8 The decimals for the API token
   */
  function decimals() external pure returns (uint8);

  /**
   * @dev name - Returns the name of the token.
   *
   * @return string The name of the API token
   */
  function name() external pure returns (string memory);

  /**
   * @dev symbol - Returns the symbol of the token, usually a shorter version of the
   * name.
   *
   * @return string The symbol of the API token
   */
  function symbol() external pure returns (string memory);

  /**
   * @dev balanceOf - Return the user API token balance
   *
   * @param holderAddress_ The address being queried
   * @return balance_ The user balance of API token
   */
  function balanceOf(
    address holderAddress_
  ) external view returns (uint256 balance_);

  /**
   * @dev totalSupply - See {IERC20-totalSupply}.
   *
   * @return uint256 The total supply of API token
   */
  function totalSupply() external pure returns (uint256);

  /**
   * @dev transfer - Doesn't move tokens at all. There was no spoon and there are no tokens.
   * Rather the quantity being 'sent' denotes the action the user is taking
   * on the EPS register, and the address they are 'sent' to is the address that is
   * being referenced by this request.
   *
   * @param to The address you are sending tokens to, interpreted by the contract according
   * to the commands in the amount field
   * @param amount Used as a combination of a control integer and a transaction type.
   *
   * @return true
   */
  function transfer(address to, uint256 amount) external returns (bool);

  /**
   * @dev getDelegationRecord - return the delegation record object for
   * the provided delegationKey argument
   *
   * @param delegationKey_ The bytes32 key for this delegation
   *
   * @return DelegationRecord The delegation record for the passed key
   */
  function getDelegationRecord(
    bytes32 delegationKey_
  ) external view returns (DelegationRecord memory);

  /**
   * @dev isValidDelegation - returns whether the arguments passed
   * result in a valid delegation
   *
   * @param hot_ The hot address for the delegation
   * @param cold_ The cold address for the delegation
   * @param collection_ The collection for the delegation. Note that address(0)
   * is passed for global delegations
   * @param usageType_ The usage type for the delegation
   * @param includeSecondary_ If this is set to true the register will also check
   * secondary delegations (i.e. non-atomic delegations)
   * @param includeRental_ If this is set to true the register will also check
   * rental delegations. Note that rental delegations ARE atomic.
   *
   * @return isValid_ Whether this is valid (true) or not (false)
   */
  function isValidDelegation(
    address hot_,
    address cold_,
    address collection_,
    uint256 usageType_,
    bool includeSecondary_,
    bool includeRental_
  ) external view returns (bool isValid_);

  /**
   * @dev getAddresses - Get all currently valid addresses for a hot address.
   * - Pass in address(0) to return records that are for ALL collections
   * - Pass in a collection address to get records for just that collection
   * - Usage type must be supplied. Only records that match usage type will be returned
   *
   * @param hot_ The hot address for the delegation
   * @param collection_ The collection for the delegation. Note that address(0)
   * is passed for global delegations
   * @param usageType_ The usage type for the delegation
   * @param includeSecondary_ If this is set to true the register will also check
   * secondary delegations (i.e. non-atomic delegations)
   * @param includeRental_ If this is set to true the register will also check
   * rental delegations. Note that rental delegations ARE atomic.
   *
   * @return addresses_ An array of addresses valid for the passed arguments
   */
  function getAddresses(
    address hot_,
    address collection_,
    uint256 usageType_,
    bool includeSecondary_,
    bool includeRental_
  ) external view returns (address[] memory addresses_);

  /**
   * @dev existsAllGlobalPrimary - Is there an all usage, global, primary
   * delegation between the passed hot and cold addresses?
   *
   * @param hot_ The hot address for the delegation
   * @param cold_ The cold address for the delegation
   *
   * @return bool If the delegation exists
   */
  function existsAllGlobalPrimary(
    address hot_,
    address cold_
  ) external view returns (bool);

  /**
   * @dev existsAllGlobalSecondary - Is there an all usage, global, primary
   * or secondary delegation between the passed hot and cold addresses?
   *
   * @param hot_ The hot address for the delegation
   * @param cold_ The cold address for the delegation
   *
   * @return bool If the delegation exists
   */
  function existsAllGlobalSecondary(
    address hot_,
    address cold_
  ) external view returns (bool);

  /**
   * @dev existsAllCollectionPrimary - Is there an all usage, collection specific,
   * primary delegation between the passed hot and cold addresses?
   *
   * @param hot_ The hot address for the delegation
   * @param cold_ The cold address for the delegation
   * @param collection_ The collection for the delegation
   *
   * @return bool If the delegation exists
   */
  function existsAllCollectionPrimary(
    address hot_,
    address cold_,
    address collection_
  ) external view returns (bool);

  /**
   * @dev existsAllCollectionSecondary - Is there an all usage, collection specific,
   * primary or secondary delegation between the passed hot and cold addresses?
   *
   * @param hot_ The hot address for the delegation
   * @param cold_ The cold address for the delegation
   * @param collection_ The collection for the delegation
   *
   * @return bool If the delegation exists
   */
  function existsAllCollectionSecondary(
    address hot_,
    address cold_,
    address collection_
  ) external view returns (bool);

  /**
   * @dev beneficiaryBalanceOf: Returns the beneficiary balance
   * Overloaded method. This returns the beneficiaries balance associated
   * with:
   *   - Not ERC1155s
   *   - the usage type for ALL usages
   *   - atomic (i.e. primary + rental) delegations.
   *
   * @param beneficiaryAddress_ The beneficiary address that we are querying
   * @param contractAddress_ The contract we are checking balances on
   *
   * @return balance_ The balance for this beneficiary
   */
  function beneficiaryBalanceOf(
    address beneficiaryAddress_,
    address contractAddress_
  ) external view returns (uint256 balance_);

  /**
   * @dev beneficiaryBalanceOf: Returns the beneficiary balance
   * Overloaded method. This returns the beneficiaries balance associated
   * with:
   *   - Not ERC1155s
   *   - a specific usage
   *   - optional atomic or include secondary
   *
   * @param beneficiaryAddress_ The beneficiary address that we are querying
   * @param contractAddress_ The contract we are checking balances on
   * @param usageType_ The usage type for the delegation
   * @param includeSecondary_ If this is set to true the register will also check
   * secondary delegations (i.e. non-atomic delegations)
   *
   * @return balance_ The balance for this beneficiary
   */
  function beneficiaryBalanceOf(
    address beneficiaryAddress_,
    address contractAddress_,
    uint256 usageType_,
    bool includeSecondary_
  ) external view returns (uint256 balance_);

  /**
   * @dev beneficiaryBalanceOf1155: Returns the beneficiary balance
   * Overloaded method. This returns the beneficiaries balance associated
   * with:
   *   - ERC1155s
   *   - the usage type for ALL usages
   *   - atomic (i.e. primary + rental) delegations.
   *
   * @param beneficiaryAddress_ The beneficiary address that we are querying
   * @param contractAddress_ The contract we are checking balances on
   * @param id_ The 1155 token Id
   *
   * @return balance_ The balance for this beneficiary
   */
  function beneficiaryBalanceOf1155(
    address beneficiaryAddress_,
    address contractAddress_,
    uint256 id_
  ) external view returns (uint256 balance_);

  /**
   * @dev beneficiaryBalanceOf1155: Returns the beneficiary balance
   * Overloaded method. This returns the beneficiaries balance associated
   * with:
   *   - ERC1155s
   *   - a specific usage
   *   - optional atomic or include secondary
   *
   * @param beneficiaryAddress_ The beneficiary address that we are querying
   * @param contractAddress_ The contract we are checking balances on
   * @param id_ The 1155 token Id
   * @param usageType_ The usage type for the delegation
   * @param includeSecondary_ If this is set to true the register will also check
   * secondary delegations (i.e. non-atomic delegations)
   *
   * @return balance_ The balance for this beneficiary
   */
  function beneficiaryBalanceOf1155(
    address beneficiaryAddress_,
    address contractAddress_,
    uint256 id_,
    uint256 usageType_,
    bool includeSecondary_
  ) external view returns (uint256 balance_);

  /**
   * @dev beneficiaryBalanceOf: Returns the beneficiary balance
   *
   * @param beneficiaryAddress_ The beneficiary address that we are querying
   * @param contractAddress_ The contract we are checking balances on
   * @param usageType_ The usage type for the delegation
   * @param erc1155_ If this is an 1155 contract
   * @param id_ If we have an 1155 contract to query this has the token Id
   * @param includeSecondary_ If this is set to true the register will also check
   * secondary delegations (i.e. non-atomic delegations)
   * @param includeRental_ If this is set to true the register will also check
   * rental delegations. Note that rental delegations ARE atomic.
   *
   * @return balance_ The balance for this beneficiary
   */
  function beneficiaryBalanceOf(
    address beneficiaryAddress_,
    address contractAddress_,
    uint256 usageType_,
    bool erc1155_,
    uint256 id_,
    bool includeSecondary_,
    bool includeRental_
  ) external view returns (uint256 balance_);

  /**
   * @dev beneficiaryOf - The beneficiary of for a token, traversing all levels of the
   * register
   *
   * @param collection_ The contract we are checking beneficiaries on
   * @param tokenId_ The token Id we are querying
   * @param usageType_ The usage type for the delegation
   * @param includeSecondary_ If this is set to true the register will also check
   * secondary delegations (i.e. non-atomic delegations)
   * @param includeRental_ If this is set to true the register will also check
   * rental delegations. Note that rental delegations ARE atomic.
   *
   * @return primaryBeneficiary_ The primary beneficiary - there can be only one
   * @return secondaryBeneficiaries_ An array of secondary beneficiaries i.e. those
   * referenced on non-atomic secondary delegations
   */
  function beneficiaryOf(
    address collection_,
    uint256 tokenId_,
    uint256 usageType_,
    bool includeSecondary_,
    bool includeRental_
  )
    external
    view
    returns (
      address primaryBeneficiary_,
      address[] memory secondaryBeneficiaries_
    );

  /**
   * @dev delegationFromColdExists - check a cold delegation exists
   *
   * @param cold_ The cold address we are querying
   * @param delegationKey_ The specific bytes32 key for a delegation
   *
   * @return bool if this exists (true) or not (false)
   */
  function delegationFromColdExists(
    address cold_,
    bytes32 delegationKey_
  ) external view returns (bool);

  /**
   * @dev delegationFromHotExists - check a hot delegation exists
   *
   * @param hot_ The hot address we are querying
   * @param delegationKey_ The specific bytes32 key for a delegation
   *
   * @return bool if this exists (true) or not (false)
   */
  function delegationFromHotExists(
    address hot_,
    bytes32 delegationKey_
  ) external view returns (bool);

  /**
   * @dev getAllForHot - Get all delegations at a hot address, formatted nicely
   *
   * @param hot_ The hot address we are querying
   *
   * @return delegationReport_ An array of delegation report objects providing
   * full details of all delegations for this hot address
   */
  function getAllForHot(
    address hot_
  ) external view returns (DelegationReport[] memory delegationReport_);

  /**
   * @dev getAllForCold - Get all delegations at a cold address, formatted nicely
   *
   * @param cold_ The cold address we are querying
   *
   * @return delegationReport_ An array of delegation report objects providing
   * full details of all delegations for this cold address
   */
  function getAllForCold(
    address cold_
  ) external view returns (DelegationReport[] memory delegationReport_);

  /**
   * @dev delegate - A direct call to setup a new proxy record(s)
   *
   * @param delegations_ An array of delegation objects.
   */
  function delegate(Delegation[] calldata delegations_) external payable;

  /**
   * @dev revokeAndDelegate - A direct call to revoke delegation(s) and
   * setup new proxy record(s)
   *
   * @param revokes_ An array of keys to revoke
   * @param delegations_ An array of delegation objects
   */

  function revokeAndDelegate(
    bytes32[] calldata revokes_,
    Delegation[] calldata delegations_
  ) external payable;

  /**
   * @dev getDelegationKey - get the link hash to the delegation metadata
   *
   * @param hot_ The hot address we are querying
   * @param cold_ The cold address we are querying
   * @param targetAddress_ The collection or contract for the scope of the delegation
   * @param tokenId_ The token ID for token delegations
   * @param startDate_ The start date of the delegation
   * @param endDate_ The end date of the delegation
   * @param scope_ The scope of this delegation (0 = global, 1 = collection, 2 = token)
   * @param class_ The class of this delegation (0 = primary, 1 = secondary, 2 = rental)
   *
   * @return key_ The delegation key
   */
  function getDelegationKey(
    address hot_,
    address cold_,
    address targetAddress_,
    uint256 tokenId_,
    uint256 usageTypesInteger_,
    uint256 startDate_,
    uint256 endDate_,
    DelegationScope scope_,
    DelegationClass class_
  ) external pure returns (bytes32 key_);

  /**
   * @dev getHotAddressLockDetails - get address lock details, both dates
   * and any bypass addresses
   *
   * @param hot_ The hot address being queried
   *
   * @return lockDetails_ The start and end date of any lock
   * @return bypassAddresses_ An array of bypass addresses
   */
  function getHotAddressLockDetails(
    address hot_
  )
    external
    view
    returns (
      LockDetails memory lockDetails_,
      address[] memory bypassAddresses_
    );

  /**
   * @dev unlockAddressUntilTime - Unlock for new delegations from cold
   * addresses until a predetermined time in the future. E.g. unlock for
   * 10 minutes while you perform delegations.
   *
   * @param lockAtTime_ The time you wish to re-lock for new delegations
   */
  function unlockAddressUntilTime(uint40 lockAtTime_) external;

  /**
   * @dev lockAddressUntilDate - Lock address until a future date when it
   * will unlock
   *
   * @param unlockDate_ The time you wish to unlock for new delegations
   */
  function lockAddressUntilDate(uint40 unlockDate_) external;

  /**
   * @dev lockAddress - Lock address until manually unlocked
   */
  function lockAddress() external;

  /**
   * @dev unlockAddress - Unlock address for new delegations from cold addresses
   */
  function unlockAddress() external;

  /**
   * @dev addBypassAddress - add an entry to the lock bypass list
   *
   * @param bypassAddress_ The address to add to your bypass list
   */
  function addBypassAddress(address bypassAddress_) external;

  /**
   * @dev removeBypassAddress - remove an entry from the lock bypass list
   *
   * @param bypassAddress_ The address to remove from your bypass list
   */
  function removeBypassAddress(address bypassAddress_) external;

  /**
   * @dev revoke - Revoking a single record with Key
   *
   * @param delegationKey_ The delegation key of the delegation you are
   * revoking
   */
  function revoke(bytes32 delegationKey_) external;

  /**
   * @dev revokeGlobalAllUsages - Revoke a delegation between
   * two parties for global scope and all usages
   *
   * @param participant2_ The second participant on a delegation (can be hot or
   * cold, the caller must be the other participant)
   */
  function revokeGlobalAllUsages(address participant2_) external;

  /**
   * @dev revokeAllForCold: Cold calls and revokes ALL
   *
   * @param cold_ The ccoldalling address
   */
  function revokeAllForCold(address cold_) external;

  /**
   * @dev revokeAllForHot: Hot calls and revokes ALL
   */
  function revokeAllForHot() external;

  /**
   * @dev deleteExpired: ANYONE can delete expired records
   *
   * @param delegationKey_ The delegation key for the item being removed
   */
  function deleteExpired(bytes32 delegationKey_) external;

  /**
   * @dev receive
   */
  receive() external payable;

  /**
   * @dev setBalanceOverride - override your default EPSAPI balance
   *
   * @param balance_ Balance override
   */
  function setBalanceOverride(uint256 balance_) external;

  /**
   * @dev withdrawETH - withdraw eth to the treasury:
   *
   * @param amount_ Amount to withdraw
   */
  function withdrawETH(uint256 amount_) external returns (bool success_);
}
