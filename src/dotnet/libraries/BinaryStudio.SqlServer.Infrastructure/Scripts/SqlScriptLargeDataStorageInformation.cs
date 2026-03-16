using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlLargeDataStorageInformation))]
    internal sealed class SqlScriptLargeDataStorageInformation : SqlScriptCodeObject<SqlLargeDataStorageInformation>
        {
        #region ctor{IServiceProvider,SqlLargeDataStorageInformation}
        public SqlScriptLargeDataStorageInformation(IServiceProvider context,SqlLargeDataStorageInformation source)
            : base(context,source)
            {
            }
        #endregion
        }
    }