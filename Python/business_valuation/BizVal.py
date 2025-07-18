# %% [markdown]
# ### Feature List
# 1. Bookkeeping
#    - Let user enter their account name and number, with single space as separator
#    - Use the availble information to create **Income Statement** and **Balance Sheet**, with the unknown value sum up as Others
#    - Use the financial statement to derive basic **financial ratios** (e.g., Gross Profit Margin, Current Ratio, etc.)
# 2. Financial Info retrieval
# 
# ### To-do List
# - [x] Take the input values and handle the errors
# - [x] Compulsory input part
# - [ ] Finding the list of acceptable account names and do the validation check
# - [ ] Create the Balance Sheet automatically
# - [ ] Create the Income Statement automatically
# - [ ] Create the Financial Ratios automatically

# %%
import yfinance as yf
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from IPython.display import clear_output
import warnings
pd.options.display.float_format = '{:,.2f}'.format
warnings.filterwarnings('ignore')

# %%
# Importing the company list from the CSV file
tickers_df = pd.read_csv('NASDAQ_NYSE_31Aug24.csv',)

# Filling the Null values with N/A
tickers_df.Sector.fillna('N/A', inplace=True)
tickers_df.Industry.fillna('N/A', inplace=True)

# Create a list of the unique sector and removing the N/A
listofsector = list(tickers_df.Sector.unique())
listofsector.remove('N/A')

# Create a dictionary for the sector
sectordictionary = {}
for each in range(len(listofsector)):
    sectordictionary[each+1] = listofsector[each]

# First function to summarize a company
def selectcompany(comp_input):
    each_company = []

    # Determining the variables that will be taken from the API
    csv_column = ['Symbol', 'Sector', 'Industry']
    company_info_column = ['address1','city','state','country']
    balancesheetcolumn = ['Total Assets', 'Total Liabilities Net Minority Interest', 'Stockholders Equity',
                         'Net Debt', 'Cash And Cash Equivalents']
    incomestatement = ['Total Revenue','EBIT','Gross Profit','Net Income']
    cashflow = ['Free Cash Flow','Capital Expenditure','Operating Cash Flow']
    
    # Determining the column names for the dataframe
    dataframecolumn = ['Ticker','Address','City','State','Country','Sector','Industry','Total Assets',
                       'Total Liabilities Net Minority Interest','Stockholders Equity','Net Debt','Cash and Cash Equivalents',
                       'Total Revenue','EBIT','Gross Profit','Net Income','Free Cash Flow','Capital Expenditure',
                       'Operating Cash Flow']

    # Appending the Ticker Symbol, Sector, and Industry
    for csv_col in csv_column:
        each_company.append(tickers_df.loc[tickers_df.Symbol.str.contains(comp_input), csv_col].iloc[0])

    # Appending the company infos
    company = yf.Ticker(comp_input)
    for com_info in company_info_column:
        try:
            each_company.append(company.info[com_info])
        except:
            each_company.append('N/A')

    # Appending the balance sheet
    try:
        balance_sheet = company.balance_sheet
        for balcol in balancesheetcolumn:
            try:
                each_company.append(balance_sheet.loc[balcol][0])
            except:
                each_company.append(np.nan)
    except:
        pass

    # Appending the income statement
    try:
        income_stmt = company.income_stmt
        for income in incomestatement:
            try:
                each_company.append(income_stmt.loc[income][0])
            except:
                each_company.append(np.nan)
    except:
        pass

    # Appending the cash flow statement
    try:
        cash_flow = company.cash_flow
        for cash in cashflow:
            try:
                each_company.append(cash_flow.loc[cash][0])
            except:
                each_company.append(np.nan)
    except:
        pass

    # Converting to dataframe
    companies_df = pd.DataFrame(data = [each_company], columns = dataframecolumn)
    companies_df = companies_df.T
    companies_df.rename(columns = {0:'Summary'}, inplace = True)
    clear_output(wait=True)
    print(companies_df)
    print(f'\n\n')

    balance_sheet.dropna(inplace = True)
    income_stmt.dropna(inplace = True)
    cash_flow.dropna(inplace = True)  

    metrics = {}
    for bal in balancesheetcolumn:
        try:
            metrics[bal] = balance_sheet.loc[bal]
        except:
            pass

    for inc in incomestatement:
        try:
            metrics[inc] = income_stmt.loc[inc]
        except:
            pass

    for cash in cashflow:
        try:
            metrics[cash] = cash_flow.loc[cash]
        except:
            pass

    # Find the common x-axis limits (dates range) across all metrics
    all_dates = [data.index for data in metrics.values() if data is not None]
    min_x, max_x = min(min(dates) for dates in all_dates), max(max(dates) for dates in all_dates)

    # Set up a 3-column grid for the plots
    n_metrics = len(metrics)
    n_cols = 3
    n_rows = (n_metrics + n_cols - 1) // n_cols  # Calculate rows needed for 3 charts per row

    fig, axes = plt.subplots(n_rows, n_cols, figsize=(18, 5 * n_rows))
    axes = axes.flatten()  # Flatten the axes array for easier iteration

    for i, (metric, data) in enumerate(metrics.items()):
        # Always set the title, xlim, and labels even if there's no data
        axes[i].set_title(f'{metric} for {comp_input}')
        axes[i].set_xlabel('Date')
        axes[i].set_ylabel('Amount')
        axes[i].set_xlim([min_x, max_x])  # Set consistent x-axis limits
        axes[i].grid(True)

        if data is not None:
            axes[i].plot(data.index, data.values, label=metric)
            axes[i].legend()

    # Hide any unused subplots
    for j in range(i + 1, len(axes)):
        fig.delaxes(axes[j])

    plt.tight_layout()
    plt.show()
    
# Function to summarize each sector
def selectsector(sector_input):
    company_list = []
    each_company = []

    # Determining the variables that will be taken from the API
    csv_column = ['Symbol', 'Sector', 'Industry']
    company_info_column = ['address1','city','state','country']
    balancesheetcolumn = ['Total Assets', 'Total Liabilities Net Minority Interest', 'Stockholders Equity',
                         'Net Debt', 'Cash And Cash Equivalents']
    incomestatement = ['Total Revenue','EBIT','Gross Profit','Net Income']
    cashflow = ['Free Cash Flow','Capital Expenditure','Operating Cash Flow']
    
    # Determining the column names for the dataframe
    dataframecolumn = ['Ticker','Address','City','State','Country','Sector','Industry','Total Assets',
                       'Total Liabilities Net Minority Interest','Stockholders Equity','Net Debt','Cash and Cash Equivalents',
                       'Total Revenue','EBIT','Gross Profit','Net Income','Free Cash Flow','Capital Expenditure',
                       'Operating Cash Flow']
    
    sectorcolumn = ['Sector', 'Total Assets', 'Total Liabilities Net Minority Interest', 'Stockholders Equity',
                    'Net Debt','Cash and Cash Equivalents','Total Revenue','EBIT','Gross Profit','Net Income',
                    'Free Cash Flow','Capital Expenditure','Operating Cash Flow']
    
    listofcompanies = list(tickers_df.loc[tickers_df["Sector"].str.contains(sector_input),'Symbol'])
    for i in range(len(listofcompanies)):
        # Appending the Ticker Symbol, Sector, and Industry
        for csv_col in csv_column:
            each_company.append(tickers_df.loc[tickers_df.Symbol.str.contains(listofcompanies[i]), csv_col].iloc[0])
    
        # Appending the company infos
        company = yf.Ticker(listofcompanies[i])
        for com_info in company_info_column:
            try:
                each_company.append(company.info[com_info])
            except:
                each_company.append('N/A')
    
        # Appending the balance sheet
        try:
            balance_sheet = company.balance_sheet.iloc[:,0]
            for balcol in balancesheetcolumn:
                try:
                    each_company.append(balance_sheet.loc[balcol])
                except:
                    each_company.append(np.nan)
        except:
            pass
    
        # Appending the income statement
        try:
            income_stmt = company.income_stmt.iloc[:,0]
            for income in incomestatement:
                try:
                    each_company.append(income_stmt.loc[income])
                except:
                    each_company.append(np.nan)
        except:
            pass
    
        # Appending the cash flow statement
        try:
            cash_flow = company.cash_flow.iloc[:,0]
            for cash in cashflow:
                try:
                    each_company.append(cash_flow.loc[cash])
                except:
                    each_company.append(np.nan)
        except:
            pass

        # Appending each company into one data frame
        company_list.append(each_company)
        each_company = []
    
    # Converting to dataframe
    companies_df = pd.DataFrame(data = company_list, columns = dataframecolumn)
    
    # Creating a list for the summary
    summary = [sectorinput]
    summary.extend(list(companies_df.iloc[:,7:19].mean()))
    sector_df = pd.DataFrame(data = [summary], columns = sectorcolumn)
    sector_df = sector_df.T
    sector_df.rename(columns = {0:'Summary'}, inplace = True)
    clear_output(wait=True)
    print(sector_df)

def selectindustry(industry_input):
    company_list = []
    each_company = []
    
    # Determining the variables that will be taken from the API
    csv_column = ['Symbol', 'Sector', 'Industry']
    company_info_column = ['address1','city','state','country']
    balancesheetcolumn = ['Total Assets', 'Total Liabilities Net Minority Interest', 'Stockholders Equity',
                         'Net Debt', 'Cash And Cash Equivalents']
    incomestatement = ['Total Revenue','EBIT','Gross Profit','Net Income']
    cashflow = ['Free Cash Flow','Capital Expenditure','Operating Cash Flow']
    
    # Determining the column names for the dataframe
    dataframecolumn = ['Ticker','Address','City','State','Country','Sector','Industry','Total Assets',
                       'Total Liabilities Net Minority Interest','Stockholders Equity','Net Debt','Cash and Cash Equivalents',
                       'Total Revenue','EBIT','Gross Profit','Net Income','Free Cash Flow','Capital Expenditure',
                       'Operating Cash Flow']
    
    industrycolumn = ['Industry', 'Total Assets', 'Total Liabilities Net Minority Interest', 'Stockholders Equity',
                      'Net Debt','Cash and Cash Equivalents','Total Revenue','EBIT','Gross Profit','Net Income',
                      'Free Cash Flow','Capital Expenditure','Operating Cash Flow']
    
    listofcompanies = list(tickers_df.loc[tickers_df["Industry"].str.contains(industry_input), 'Symbol'])
    for i in range(len(listofcompanies)):
        # Appending the Ticker Symbol, Sector, and Industry
        for csv_col in csv_column:
            each_company.append(tickers_df.loc[tickers_df.Symbol.str.contains(listofcompanies[i]), csv_col].iloc[0])
    
        # Appending the company infos
        company = yf.Ticker(listofcompanies[i])
        for com_info in company_info_column:
            try:
                each_company.append(company.info[com_info])
            except:
                each_company.append('N/A')
    
        # Appending the balance sheet
        try:
            balance_sheet = company.balance_sheet.iloc[:,0]
            for balcol in balancesheetcolumn:
                try:
                    each_company.append(balance_sheet.loc[balcol])
                except:
                    each_company.append(np.nan)
        except:
            pass
    
        # Appending the income statement
        try:
            income_stmt = company.income_stmt.iloc[:,0]
            for income in incomestatement:
                try:
                    each_company.append(income_stmt.loc[income])
                except:
                    each_company.append(np.nan)
        except:
            pass
    
        # Appending the cash flow statement
        try:
            cash_flow = company.cash_flow.iloc[:,0]
            for cash in cashflow:
                try:
                    each_company.append(cash_flow.loc[cash])
                except:
                    each_company.append(np.nan)
        except:
            pass
        company_list.append(each_company)
        each_company = []
    companies_df = pd.DataFrame(data = company_list, columns = dataframecolumn)
    summary = [industry_input]
    summary.extend(list(companies_df.iloc[:,7:19].mean()))
    industry_df = pd.DataFrame(data = [summary], columns = industrycolumn)
    industry_df = industry_df.T
    industry_df.rename(columns = {0:'Summary'}, inplace = True)
    clear_output(wait=True)
    print(industry_df)

intro = '''Welcome to the bookkeeping and financial info service:
Now we have two services available:
1. Bookkeeping services
    Enter your financial info and create a financial statement and summary
2. Financial info search:
    Retrieve the information of the company/industry you select from Yahoo Finance'''


print(intro)
clear_output(wait = True)

while True:
    service_type = input('Please enter the service type:\n1 = Bookkeeping\n2 = Financial info search\nq = Quit ').strip().lower()
    if service_type == '1':
        while True:
            #print out the options
            print("\nSelect an option:")
            print("1. Enter financial data")
            print("2. Add more terms")
            print("3. Print summary table")
            print("4. Exit")

            option = input("Enter the number of your choice: ")
            if option == '1':
                compulsory_accounts = [
                    "Total Assets",
                    "Total Liabilities",
                    "Total Shareholders' Equity",
                    "Net Debt",
                    "Cash",
                    "Revenues",
                    "Gross Profit",
                    "Operating Profit",
                    "Net Income",
                    "Free Cash Flow",
                    "Operating Cash Flow",
                    "Capital Expenditure"]

                accounts = compulsory_accounts.copy()
                financial_data = {}
                
                #show the list of compulsory account
                available_indices = list(range(1, len(accounts) + 1))
                print("\nSelect from the following financial accounts by entering the corresponding number:")
                for i, term in enumerate(accounts):
                    print(f"{i+1}. {term}")
                    

                #User enter the value for each accounts continually
                for term in accounts:
                    while True:
                        value = input(f"Enter the value for {term}: ")
                        try:
                            financial_data[term] = float(value)
                            break
                        except ValueError:
                            print("Invalid value. Please enter a valid number.")

                
                #print out the temporary list of input value for user  
                print("\nCurrent Entries:")
                if not financial_data:
                    print("No data entered yet.")
                else:
                    for term, value in financial_data.items():
                        print(f"{term}: {value if value is not None else 'Not Provided'}")

                        clear_output(wait = True)


                # Check if all compulsory accounts are provided
                missing_accounts = [term for term in accounts if term not in financial_data]
                if missing_accounts:
                    print("\nWarning: You have not provided values for the following accounts:")
                    for term in missing_accounts:
                        print(f"- {term}")
                    print("Please provide values for all required accounts.")
                else:
                    print("\nCurrent Entries:")
                    if not financial_data:
                        print("No data entered yet.")
                    else:
                        for term, value in financial_data.items():
                            print(f"{term}: {value if value is not None else 'Not Provided'}")
                

                        clear_output(wait = True)



            #Users add the additional accounts that they have
            elif option =='2':
                #print out the options
                print("\nSelect the table to input additional accounts")
                print("1. Income Statement")
                print("2. Balance Sheet")
                print("3. Exit")

                income_key = ['Revenues','Cost of Goods Sold','Gross Profit','Selling, General & Administrative Expenses',
                              'Research & Development Expense','Other Operating Expense', 'Operating Profit', 'Interest Expense',
                              'Interest Income','Other Non-Operating Expense','Pre-Tax Income','Income Taxes','Net Income']
                
                balance_key = ['Cash', 'Short-Term Investments', 'Accounts Receivable', 'Inventory', 'Other Current Assets',
                               'Total Current Assets', 'Long-Term Investments', 'Net Property, Plant & Equipment', 
                               'Other Non-Current Assets', 'Total Non-Current Assets', 'Total Assets','Accounts Payable', 'Short-Term Debt', 
                               'Other Current Liabilities','Total Current Liabilities', 'Long-Term Debt', 'Capitalized Lease', 'Other Non-Current Liabilities', 
                               'Total Non-Current Liabilities', 'Total Liabilities', 'Common Equity', 'Preferred Equity', 'Retained Earnings', 
                               'Comprehensive Income', "Total Shareholders' Equity", "Total Liabilities & Shareholders' Equity"]

                balance_category = ['Current Asset', 'Current Asset', 'Current Asset', 'Current Asset', 'Current Asset',
                                    'Total Current Asset', 'Non-Current Assets', 'Non-Current Assets',
                                    'Non-Current Assets', 'Total Non-Current Assets', 'Total Assets', 'Current Liabilities',
                                    'Current Liabilities', 'Current Liabilities', 'Total Current Liabilities', 'Non-Current Liabilities',
                                    'Non-Current Liabilities', 'Non-Current Liabilities', 'Total Non-Current Liabilities', 'Total Liabilities',
                                    "Shareholders' Equity", "Shareholders' Equity", "Shareholders' Equity", "Shareholders' Equity",
                                    "Total Shareholders' Equity", "Total Liabilities & Shareholders' Equity"]

                index_2_levels = pd.MultiIndex.from_arrays([balance_category, balance_key], names=['Category', 'Account'])

                income_accounts = dict.fromkeys(income_key, 0)
                balance_accounts = dict.fromkeys(balance_key, 0)

                def print_income_statement(financial_data: dict):
                    print("\nINCOME STATEMENT")
                    print("=" * 80)
                    se_income = pd.Series(financial_data)
                    se_income = se_income[se_income != 0]
                    print(se_income.to_string())
                    print("=" * 80)

                def print_balance_sheet(financial_data: dict):
                    print("\nBALANCE SHEET")
                    print("=" * 100)
                    se_balance = pd.Series(financial_data.values(), index=index_2_levels)
                    se_balance = se_balance[se_balance != 0]
                    print(se_balance.to_string())
                    print("=" * 100)
                
                
                income_statement_accounts= income_key.copy()
                balance_sheet_accounts= balance_key.copy()

                account_type = int(input('Enter your choice:'))
            
                if account_type == 1: 
                    available_indices1 = list(range(1, len(income_key) + 1))
                    print("\nSelect from the following financial accounts by entering the corresponding number:")
                    for i, term in enumerate(income_key):
                        print(f"{i+1}. {term}")
               
                    while True:
                        input_str = input("Enter the numbers of the accounts you want to add, separated by commas (or type 'done' when finished): ")
                        if input_str.lower() == 'done':
                            break
                        try:
                            selected_indices1 = [int(num.strip()) for num in input_str.split(',')]
                        except ValueError:
                            print("Invalid input. Please enter a valid number.")
                            continue
                        for index in selected_indices1:
                            if index in available_indices1:
                                term = income_statement_accounts[index - 1]
                                value = input(f"Enter the value for {term}: ")
                            try:
                                financial_data[term] = float(value)
                            except ValueError:
                                print("Invalid value. Please enter a valid number.")
                                continue
                    
                elif account_type == 2: 
                    available_indices2 = list(range(1, len(balance_key) + 1))
                    print("\nSelect from the following financial accounts by entering the corresponding number:")
                    for i, term in enumerate(balance_key):
                        print(f"{i+1}. {term}")
                    while True:
                        input_str = input("Enter the numbers of the accounts you want to add, separated by commas (or type 'done' when finished): ")
                        if input_str.lower() == 'done':
                            break
                        try:
                            selected_indices2 = [int(num.strip()) for num in input_str.split(',')]
                        except ValueError:
                            print("Invalid input. Please enter a valid number.")
                            continue
                        for index in selected_indices2:
                            if index in available_indices2:
                                term = balance_sheet_accounts[index - 1]
                                value = input(f"Enter the value for {term}: ")
                            try:
                                financial_data[term] = float(value)
                            except ValueError:
                                print("Invalid value. Please enter a valid number.")
                                continue     

                elif account_type == 3:
                    pass
                else:
                    print("Invalid option. Please enter a valid number.")
                    continue
        
            # print out all information in summary table (can be change to print out Financial Statements)
            elif option == '3':  
                for k, v in financial_data.items():
                        if k in balance_key:
                            balance_accounts[k] = v
                        elif k in income_key:
                            income_accounts[k] = v
                # Income Statement
                if income_accounts['Gross Profit'] == 0:
                    income_accounts['Gross Profit'] = income_accounts['Revenues'] - income_accounts['Cost of Goods Sold']
                else:
                    income_accounts['Cost of Goods Sold'] = income_accounts['Revenues'] - income_accounts['Gross Profit']
                
                if income_accounts['Operating Profit'] == 0:
                    income_accounts['Operating Profit'] = income_accounts['Gross Profit'] - income_accounts['Selling, General & Administrative Expenses'] - income_accounts['Research & Development Expense'] - income_accounts['Other Operating Expense']
                else:
                    income_accounts['Other Operating Expense'] = income_accounts['Gross Profit'] - income_accounts['Operating Profit'] - income_accounts['Selling, General & Administrative Expenses'] - income_accounts['Research & Development Expense']

                if income_accounts['Pre-Tax Income'] == 0:
                    income_accounts['Pre-Tax Income'] = income_accounts['Operating Profit'] - income_accounts['Interest Expense'] + income_accounts['Interest Income'] - income_accounts['Other Non-Operating Expense']
                else:
                    income_accounts['Other Non-Operating Expense'] = income_accounts['Operating Profit'] - income_accounts['Interest Expense'] + income_accounts['Interest Income'] - income_accounts['Pre-Tax Income']
                
                if income_accounts['Net Income'] == 0:
                    income_accounts['Net Income'] = income_accounts['Pre-Tax Income'] - income_accounts['Income Taxes']
                else:
                    income_accounts['Income Taxes'] = income_accounts['Net Income'] - income_accounts['Pre-Tax Income']
                
                # Balance sheet
                if balance_accounts['Total Current Assets'] == 0:
                    balance_accounts['Total Current Assets'] = balance_accounts['Cash'] + balance_accounts['Inventory'] + balance_accounts['Short-Term Investments'] + balance_accounts['Accounts Receivable'] + balance_accounts['Other Current Assets']
                else:
                    balance_accounts['Other Current Assets'] = balance_accounts['Total Current Assets'] - balance_accounts['Cash'] - balance_accounts['Inventory'] - balance_accounts['Short-Term Investments'] - balance_accounts['Accounts Receivable']
                
                if balance_accounts['Total Non-Current Assets'] == 0:
                    balance_accounts['Total Non-Current Assets'] = balance_accounts['Long-Term Investments'] + balance_accounts['Net Property, Plant & Equipment'] + balance_accounts['Other Non-Current Assets']
                else:
                    balance_accounts['Other Non-Current Assets'] = balance_accounts['Total Non-Current Assets'] - balance_accounts['Long-Term Investments'] - balance_accounts['Net Property, Plant & Equipment']
                
                if balance_accounts['Total Current Liabilities'] == 0:
                    balance_accounts['Total Current Liabilities'] = balance_accounts['Accounts Payable'] + balance_accounts['Short-Term Debt'] + balance_accounts['Other Current Liabilities']
                else:
                    balance_accounts['Other Current Liabilities'] = balance_accounts['Total Current Liabilities'] - balance_accounts['Accounts Payable'] - balance_accounts['Short-Term Debt']    
                
                if balance_accounts['Total Non-Current Liabilities'] == 0:
                    balance_accounts['Total Non-Current Liabilities'] = balance_accounts['Long-Term Debt'] + balance_accounts['Capitalized Lease'] + balance_accounts['Other Non-Current Liabilities']
                else:
                    balance_accounts['Other Non-Current Liabilities'] = balance_accounts['Total Non-Current Liabilities'] - balance_accounts['Long-Term Debt'] - balance_accounts['Capitalized Lease']    
                
                if balance_accounts["Total Shareholders' Equity"] == 0:
                    balance_accounts["Total Shareholders' Equity"] = balance_accounts['Common Equity'] + balance_accounts['Preferred Equity'] + balance_accounts['Retained Earnings'] + balance_accounts['Comprehensive Income']
                else:
                    balance_accounts['Retained Earnings'] = balance_accounts["Total Shareholders' Equity"] - balance_accounts['Common Equity'] - balance_accounts['Preferred Equity'] - balance_accounts['Comprehensive Income']
                
                if balance_accounts['Total Assets'] == 0:
                    balance_accounts['Total Assets'] = balance_accounts['Total Current Assets'] + balance_accounts['Total Non-Current Assets']
                else:
                    if balance_accounts['Total Current Assets'] == 0:
                        balance_accounts['Total Current Assets'] = balance_accounts['Total Assets'] - balance_accounts['Total Non-Current Assets']


                if balance_accounts['Total Liabilities'] == 0:
                    balance_accounts['Total Liabilities'] = balance_accounts['Total Current Liabilities'] + balance_accounts['Total Non-Current Liabilities']
                
                balance_accounts["Total Liabilities & Shareholders' Equity"] = balance_accounts['Total Liabilities'] + balance_accounts["Total Shareholders' Equity"]            
                
                print("\nFinancial Statement Generator")
                print("1. Financial Statement")
                print("2. Financial Ratio")
                print("3. Exit")
                option_3 = input("Select an option: ").strip()
                if option_3 == '1':
                    print_income_statement(income_accounts)
                    print_balance_sheet(balance_accounts)
                elif option_3 == '2':
                    all_accounts = {}
                    all_accounts.update(financial_data)
                    all_accounts.update(balance_accounts)
                    all_accounts.update(income_accounts)
                    for k, v in all_accounts.items():
                        if v == 0:
                            all_accounts[k] = np.nan
                    
                    # Profitability
                    gross_profit_margin = all_accounts['Gross Profit'] / all_accounts['Revenues']
                    operating_profit_margin = all_accounts['Operating Profit'] / all_accounts['Revenues']
                    pretax_profit_margin = all_accounts['Pre-Tax Income'] / all_accounts['Revenues']
                    net_profit_margin = all_accounts['Net Income'] / all_accounts['Revenues']
                    return_on_equity = all_accounts['Net Income'] / all_accounts["Total Shareholders' Equity"]
                    return_on_asset = all_accounts['Net Income'] / all_accounts["Total Assets"]

                    prof_account_name = ['Gross Profit Margin', 'Operating Margin', 'Income before Tax Margin', 'Net Margin',
                                    'Return on Equity', 'Return on Asset']
                    prof_account_value = [gross_profit_margin, operating_profit_margin, pretax_profit_margin, net_profit_margin,
                                    return_on_equity, return_on_asset]

                    prof_account_dict = dict(zip(prof_account_name, prof_account_value))

                    # Financial Strength / Leverage
                    net_debt_to_asset = all_accounts['Net Debt'] / all_accounts['Total Assets']
                    net_debt_to_equity = all_accounts['Net Debt'] / all_accounts["Total Shareholders' Equity"]
                    interest_coverage_ratio = all_accounts['Operating Profit'] / all_accounts['Interest Expense']

                    fin_account_name = ['Net Debt Ratio', 'Net Debt to Equity', 'Interest Coverage Ratio']
                    fin_account_value = [net_debt_to_asset, net_debt_to_equity, interest_coverage_ratio]

                    fin_account_dict = dict(zip(fin_account_name, fin_account_value))

                    # Liquidity
                    current_ratio = all_accounts['Total Current Assets'] / all_accounts['Total Current Liabilities']
                    quick_ratio = (all_accounts['Total Current Assets'] - all_accounts['Inventory']) / all_accounts['Total Current Liabilities']

                    li_account_name = ['Current Ratio', 'Quick Ratio']
                    li_account_value = [current_ratio, quick_ratio]

                    li_account_dict = dict(zip(li_account_name, li_account_value))

                    # Operating
                    accounts_receivable_turnover = all_accounts['Revenues'] / all_accounts['Accounts Receivable']
                    accounts_receivable_days = 365 / accounts_receivable_turnover
                    payable_turnover = all_accounts['Cost of Goods Sold'] / all_accounts['Accounts Payable']
                    payable_days = 365 / payable_turnover
                    inventory_turnover = all_accounts['Cost of Goods Sold'] / all_accounts['Inventory']    
                    inventory_days = 365 / inventory_turnover
                    cash_coversion_cycle = accounts_receivable_days + inventory_days - payable_days

                    op_account_name = ['Accounts Receivable Turnover', 'Accounts Receivable Days', 
                                    'Accounts Payable Turnover', 'Accounts Payable Days',
                                    'Inventory Turnover', 'Inventory Days', 'Cash Conversion Cycle']
                    op_account_value = [accounts_receivable_turnover, accounts_receivable_days,
                                    payable_turnover, payable_days,
                                    inventory_turnover, inventory_days, cash_coversion_cycle]

                    op_account_dict = dict(zip(op_account_name, op_account_value))

                    ratio_category = ['Profitability'] * len(prof_account_name) + ['Financial Strength / Leverage'] * len(fin_account_name) + ['Liquidity'] * len(li_account_name) + ['Operating'] * len(op_account_name)
                    ratio_account = prof_account_name + fin_account_name + li_account_name + op_account_name
                    index_ratio_2_levels = pd.MultiIndex.from_arrays([ratio_category, ratio_account], names=['Category', 'Account'])

                    all_ratio_dict = {}
                    all_ratio_dict.update(prof_account_dict)
                    all_ratio_dict.update(fin_account_dict)
                    all_ratio_dict.update(li_account_dict)
                    all_ratio_dict.update(op_account_dict)
                    print(pd.Series(all_ratio_dict.values(), index=index_ratio_2_levels).to_string())
                    
                elif option_3 == '3':
                    break 
                else:
                    print('Invalid option. Please enter again')

                    clear_output(wait = True)

            #exit the program
            elif option =='4':
                break 
            else: 
                print('Please enter the correct value.')

    elif service_type == '2':
        while True:
            try:
                print(f'''\nWhat information would you like to view?
1. Company
2. Sector
3. Industry''')
                infoinput = int(input('\nInsert Here: '))
                if infoinput > 0 and infoinput < 4:
                    break
                else:
                    print(f'\nValue has to be between 1 and 3')
                    continue
            except:
                print(f'\nInput has to be integer')
                continue
        
        if infoinput == 1:
            tickinput = input(f'\nInput company ticker here: ').strip().upper()
            if tickinput in list(tickers_df['Symbol']):
                print(f'\nLoading.....\n')
                selectcompany(tickinput)
            else:
                print(f'\nTicker is not on the list of companies')
        elif infoinput == 2:
            while True:
                try:
                    print(f'''\nWhat sector would you like to view?''')
                    for key in sectordictionary:
                        print(f'{key}. {sectordictionary[key]}')
                    sectorinput = int(input('\nInput Here:'))
                    if sectorinput > 0 and sectorinput < 13:
                        print(f'\nLoading.....\n')
                        break
                    else:
                        print(f'\nValue has to be between 1 and 12')
                        continue
                except:
                    print(f'\nInput has to be integer')
                    continue
            sect_select = sectordictionary[sectorinput]
            selectsector(sect_select)
        
        elif infoinput == 3:
            while True:
                try:
                    print(f'''\nWhat sector would you like to view?''')
                    for key in sectordictionary:
                        print(f'{key}. {sectordictionary[key]}')
                    sectorinput = int(input('\nInput Here: '))
                    if sectorinput > 0 and sectorinput < 13:
                        break
                    else:
                        print(f'\nValue has to be between 1 and 12')
                        continue
                except:
                    print(f'\nInput has to be integer')
                    continue
        
            while True:
                try:
                    print(f'\nWhat industry would you like to view?')
                    listofindustry = list(tickers_df.loc[tickers_df["Sector"].str.contains(sectordictionary[sectorinput]), 'Industry'].unique())
                    
                    industrydict = {}
                    for each_ind in range(len(listofindustry)):
                        industrydict[each_ind+1] = listofindustry[each_ind]
                        
                    for key in industrydict:
                        print(f'{key}. {industrydict[key]}')
                        
                    indinput = int(input('\nInput Here: '))
                    if indinput > 0 and indinput < (len(listofindustry)+1):
                        print(f'\nLoading.....\n')
                        break
                    else:
                        print(f'\nValue has to be between 1 and {len(listofindustry)}')
                        continue
                except:
                    print(f'\nInput has to be integer')
                    continue
        
            ind_select = industrydict[indinput]
            selectindustry(ind_select)
    elif service_type == 'q':
        clear_output(wait=True)
        print(f"Good Bye")
        break
    else:
        print('Please enter the correct value.')

# %%
# customer will enter the value for 12 compulsory metrics continually -> can't skip or fill 0 
# clear output 
# reconsider the metrics after deciding the model 


