using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptProcedureDefinition<T> : SqlScriptCodeObject<T>,ISqlScriptProcedureDefinition
        where T: SqlProcedureDefinition
        {
        [UsedImplicitly][Field] public SqlObjectIdentifier Name { get; }
        [UsedImplicitly][Field] public Boolean IsForReplication { get; }
        [UsedImplicitly][Field] public Int32? Number { get; }

        #region ctor{IServiceProvider,T}
        protected SqlScriptProcedureDefinition(IServiceProvider context,T source)
            : base(context, source)
            {
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return Name.ToString();
            }
        #endregion
        }

    [SqlScriptObject(typeof(SqlProcedureDefinition))]
    internal sealed class SqlScriptProcedureDefinition : SqlScriptProcedureDefinition<SqlProcedureDefinition>
        {
        #region ctor{IServiceProvider,SqlProcedureDefinition}
        public SqlScriptProcedureDefinition(IServiceProvider context,SqlProcedureDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }