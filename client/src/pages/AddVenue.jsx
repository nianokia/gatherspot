import { BackButton } from '../constants/constant.jsx';

const AddVenue = () => {
  return (
    <div className="AddVenue">
      <BackButton />
      <h1>Add Venue Page</h1>
      <form className='AddVenueForm'>
        <div className="formGroup">
          <label htmlFor="name">Name:</label>
          <input type="text" id="name" name="name" required placeholder="Name" />
        </div>
        <div className="formGroup">
          <label htmlFor="address">Address:</label>
          <input type="text" id="address" name="address" required placeholder="Address" />
        </div>
        <div className="formGroup">
          <label htmlFor="city">City:</label>
          <input type="text" id="city" name="city" required placeholder="City" />
        </div>
        <div className="formGroup">
          <label htmlFor="state">State:</label>
          <input type="text" id="state" name="state" required placeholder="State" />
        </div>
        <div className="formGroup">
          <label htmlFor="country">Country:</label>
          <input type="text" id="country" name="country" required placeholder="Country" />
        </div>
        <div className="formGroup">
          <label htmlFor="zip_code">Zip Code:</label>
          <input type="text" id="zip_code" name="zip_code" placeholder="Zip Code" />
        </div>
        <div className="formGroup">
          <label htmlFor="capacity">Capacity:</label>
          <input type="number" id="capacity" name="capacity" min="1" placeholder="Capacity" />
        </div>
        <div>
          <button type="submit" className="createBtn">Create Venue</button>
        </div>
      </form>
    </div>
  );
};

export default AddVenue;