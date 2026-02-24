using System;
using System.Collections.Generic;
using System.Diagnostics;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    public abstract class DataSchemaModelAnnotation : DataSchemaModelElement
        {
        [DebuggerBrowsable(DebuggerBrowsableState.Never)] protected internal override IList<DataSchemaModelAnnotation> Annotations { get{ return base.Annotations; }}

        #region ctor{DataSchemaModel}
        protected DataSchemaModelAnnotation(DataSchemaModel Scope)
            : base(Scope)
            {
            }
        #endregion
        }
    }
