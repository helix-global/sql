using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlChangeTrackingContext))]
    internal sealed class SqlScriptChangeTrackingContext : SqlScriptCodeObject<SqlChangeTrackingContext>
        {
        #region ctor{IServiceProvider,SqlChangeTrackingContext}
        public SqlScriptChangeTrackingContext(IServiceProvider context,SqlChangeTrackingContext source)
            : base(context,source)
            {
            }
        #endregion
        }
    }